import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/styles/decoration.dart';

import '../../components/button.dart';
import '../../models/customer.dart';
import '../../services/store.dart';
import '../../styles/color.dart';
import '../../styles/text.dart';

class Stops extends StatefulWidget {
  CustomerModel customerCurrent;
  Stops({Key? key, required this.customerCurrent}) : super(key: key);

  @override
  State<Stops> createState() => _StopsState();
}

class _StopsState extends State<Stops> {
  late Size size;
  late List<StopModel> stopList = [];
  late int stopSelect = -1;

  @override
  void initState() {
    super.initState();
    getDataStops();
  }

  getDataStops() async {
    await getStopsList().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        stopList.clear();
        setState(() {
          answer.body
              .map((e) => stopList.add(StopModel.fromService(e)))
              .toList();

          ///Checar el link del ultimo elemento
          stopList.removeLast();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
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
        child: Column(
          children: [fakeStop(), typesOfStops(), buttonSelectStop()],
        ),
      ),
    );
  }

  Widget buttonSelectStop() {
    return Visibility(
        visible: stopSelect != -1 ? true : false,
        child: Container(
            margin:
                const EdgeInsets.only(left: 15, right: 15, bottom: 30, top: 30),
            width: double.infinity,
            height: 40,
            alignment: Alignment.center,
            child: ButtonJunghanns(
              decoration: Decorations.blueBorder12,
              fun: () => showConfirmStop(),
              label: "Seleccionar parada",
              style: TextStyles.white17_5,
            )));
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
            child: Text(stopList
                .firstWhere((element) => element.id == stopSelect)
                .description)));
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

  funSelectStop() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      if (Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              widget.customerCurrent.lat,
              widget.customerCurrent.lng) <
          30000) {
        //
        log("Parada numero $stopSelect");

        Map<String, dynamic> data = {
          "id_cliente": widget.customerCurrent.idClient,
          "id_parada": stopSelect,
          "lat": "${widget.customerCurrent.lat}",
          "lon": "${widget.customerCurrent.lng}",
          "id_data_origen": widget.customerCurrent.id,
          "tipo": widget.customerCurrent.typeVisit.characters.first
        };
        log("Parada Data $data");

        ///
        await setStop(data).then((answer) {
          if (answer.error) {
            Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              webShowClose: true,
            );
          } else {
            //
            log("Parada asignada");
            Fluttertoast.showToast(
              msg: "Parada asignada con exito",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              webShowClose: true,
            );
            Navigator.pop(context);
            //
          }
        });
      } else {
        Fluttertoast.showToast(
          msg: "Lejos del domicilio",
          timeInSecForIosWeb: 16,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          webShowClose: true,
        );
      }
    } else {
      log("permission $permission");
    }
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

  Widget stop(String image, String text, int id) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(4),
          decoration:
              stopSelect == id ? Decorations.blueCard : const BoxDecoration(),
          child: Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(image))),
                  )),
              Expanded(
                  flex: 1,
                  child: Container(
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        text,
                        style: TextStyles.grey17Itw,
                        textAlign: TextAlign.center,
                      )))
            ],
          )),
      onTap: () {
        log("Parada en falso");
        setState(() {
          if (stopSelect != id) {
            stopSelect = id;
          } else {
            stopSelect = -1;
          }
        });
      },
    );
  }

  Widget typesOfStops() {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            margin: const EdgeInsets.only(top: 20),
            child: GridView.custom(
              gridDelegate: SliverWovenGridDelegate.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 15,
                pattern: const [
                  WovenGridTile(.8),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) => stop(stopList[index].icon,
                    stopList[index].description, stopList[index].id),
                childCount: stopList.length,
              ),
            )));
  }
}
