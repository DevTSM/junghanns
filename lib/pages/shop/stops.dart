import 'dart:async';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:provider/provider.dart';

import '../../models/customer.dart';
import '../../services/store.dart';
import '../../styles/color.dart';
import '../../styles/text.dart';

class Stops extends StatefulWidget {
  CustomerModel customerCurrent;
  int distance;
  Stops({Key? key, required this.customerCurrent, required this.distance})
      : super(key: key);

  @override
  State<Stops> createState() => _StopsState();
}

class _StopsState extends State<Stops> {
  late ProviderJunghanns provider;
  late StopModel stopCurrent;
  late Size size;
  late List<StopModel> stopList = [];
  late bool isLoading;
  //
  late double latStop, lngStop;

  @override
  void initState() {
    super.initState();
    stopCurrent = StopModel.fromState();
    isLoading = true;
    //
    latStop = lngStop = 0;
    //
    getDataStops();
  }

  getDataStops() async {
    Timer(const Duration(milliseconds: 1000), () async {
      if (provider.connectionStatus < 4) {
    await getStopsList().then((answer) {
      setState(() {
        isLoading = false;
      });
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin paradas",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        stopList.clear();
        answer.body.map((e) {
          stopList.add(StopModel.fromService(e));
        }).toList();
      }
    });
      }else{
        setState(() {
        isLoading = false;
      });
      }
    });
  }

  showConfirmStop() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: size.width * .75,
              decoration: Decorations.whiteS1Card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  textConfirmWayToStop(),
                  textWayToStop(),
                  buttomsSale()
                ],
              ),
            ),
          );
        });
  }

  funSelectStop() async {
    setState(() {
      isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      latStop = _currentLocation.latitude;
      lngStop = _currentLocation.longitude;
      log("Coordenadas : $latStop, $lngStop  ${widget.customerCurrent.lat} ${widget.customerCurrent.lng} ===> ${Geolocator.distanceBetween(
                  _currentLocation.latitude,
                  _currentLocation.longitude,
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng)} <====> ${widget.distance}" );
      if (Geolocator.distanceBetween(
                  _currentLocation.latitude,
                  _currentLocation.longitude,
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng) <
              widget.distance) {
          Map<String, dynamic> data = {
            "id_cliente": widget.customerCurrent.idClient.toString(),
            "id_parada": stopCurrent.id,
            "lat": "$latStop",
            "lon": "$lngStop",
            "id_data_origen": widget.customerCurrent.id,
            "tipo": widget.customerCurrent.typeVisit.characters.first
          };
          Map<String, dynamic> dataOff = {
            "idCustomer": widget.customerCurrent.idClient,
            "idStop": stopCurrent.id,
            "lat": "${widget.customerCurrent.lat}",
            "lng": "${widget.customerCurrent.lng}",
            "idOrigin": widget.customerCurrent.id,
            "fecha":DateTime.now().toString(),
            "type": widget.customerCurrent.typeVisit.characters.first,
            "isUpdate":0
          };
           int id=await handler.insertStopOff(dataOff);
            data["id_local"]=id;
          await postStop(data).then((answer) {
            setState(() {
              isLoading = false;
            });
            if (!answer.error){
              handler.updateStopOff(1,id );
            }else{
              provider.isNeedAsync=true;
            }
          });
          log("aqui ................");
          widget.customerCurrent.addHistory({
    'fecha':DateTime.now().toString(),
    'tipo':"PARADA",
    'descripcion':"${stopCurrent.id} - ${stopCurrent.description}",
    'importe':0,
    'cantidad':1
  });
          widget.customerCurrent.setType(7);
          Fluttertoast.showToast(
                msg: "Parada asignada con exito",
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
              Navigator.pop(context);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Lejos del domicilio",
          timeInSecForIosWeb: 16,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    } else {
      Navigator.pop(context);
      log("permission $permission");
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.whiteJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.whiteJ,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menu.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: Container(
          color: ColorsJunghanns.whiteJ,
          child: Stack(children: [
            Column(
              children: [
                provider.connectionStatus == 4? const WithoutInternet():provider.isNeedAsync?const NeedAsync():Container(),
                fakeStop(),
                typesOfStops(),
              ],
            ),
            Visibility(visible: isLoading, child: const LoadingJunghanns())
          ])),
      bottomNavigationBar: bottomBar(() {}, 2, isHome: false, context: context),
    );
  }

  Widget textConfirmWayToStop() {
    return Container(
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyles.blueJ22Bold, child: const Text("Confirmación")));
  }

  Widget textWayToStop() {
    return Container(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyles.greenJ15Bold,
            child: Text("${stopCurrent.id} | ${stopCurrent.description}")));
  }

  Widget buttomsSale() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buttomSale(
              "Si",
              () => () {
                    Navigator.pop(context);
                      funSelectStop();
                  },
              Decorations.blueBorder12),
          buttomSale(
              "No",
              () => () {
                    stopCurrent = StopModel.fromState();
                    log("Stop ID: ${stopCurrent.id}");
                    Navigator.pop(context);
                  },
              Decorations.redCard),
        ],
      ),
    );
  }

  Widget buttomSale(String op, Function fun, BoxDecoration deco) {
    return GestureDetector(
      onTap: fun(),
      child: Container(
          alignment: Alignment.center,
          width: size.width * 0.22,
          height: size.width * 0.11,
          decoration: deco,
          child: DefaultTextStyle(
              style: TextStyles.white18SemiBoldIt,
              child: Text(
                op,
              ))),
    );
  }

  Widget fakeStop() {
    return Container(
        padding: EdgeInsets.only(
            right: 10, left: 15, top: 10, bottom: size.height * .02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorsJunghanns.blueJ,
                )),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parada en Falso",
                          style: TextStyles.blueJ30BoldIt,
                        ),
                        Text(
                          widget.customerCurrent.name,
                          style: TextStyles.green18Itw,
                        ),
                      ],
                    ))),
          ],
        ));
  }

  Widget stop(StopModel stop) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(stop.icon))),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        "${stop.id} | ${stop.description}",
                        style: TextStyles.grey17Itw,
                        textAlign: TextAlign.center,
                      )))
            ],
          )),
      onTap: () {
        stopCurrent = stop;
        log("Stop ID: ${stopCurrent.id}");
        showConfirmStop();
      },
    );
  }

  Widget typesOfStops() {
    return Expanded(
            child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                margin: const EdgeInsets.only(top: 20),
                child: FutureBuilder(
                    future: handler.retrieveStop(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<StopModel>> snapshot) {
                      if (snapshot.hasData) {
                        return GridView.custom(
                          gridDelegate: SliverWovenGridDelegate.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 10,
                            pattern: const [
                              WovenGridTile(.8),
                            ],
                          ),
                          childrenDelegate: SliverChildBuilderDelegate(
                            (context, index) => index != snapshot.data?.length
                                ? stop(snapshot.data![index])
                                : Container(),
                            childCount: snapshot.data?.length,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    })));
  }
}
