import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/transfer.dart';
import 'package:junghanns/pages/transfer/transfer_solicitud.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/transfer.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';

class Transfer extends StatefulWidget {
  const Transfer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  late ProviderJunghanns provider;
  late List<TransferModel> transfers;
  late List<Map<String, dynamic>> products, routes;
  late Map<String, dynamic> product, route;
  late TextEditingController count, descripcion;
  late LocationData currentLocation;
  late Size size;
  late int itemBar;
  late int amount;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    transfers = [];
    count = TextEditingController();
    descripcion = TextEditingController();
    currentLocation = LocationData.fromMap({});
    amount = 0;
    itemBar = 1;
    isLoading = true;
    getDataTransfer();
  }

  setCurrentLocation() async {
    try {
      Location locationInstance = Location();
      PermissionStatus permission = await locationInstance.hasPermission();
      if (permission == PermissionStatus.granted) {
        locationInstance.changeSettings(accuracy: LocationAccuracy.high);
        if (await locationInstance.serviceEnabled()) {
          currentLocation = await locationInstance
              .getLocation()
              .timeout(const Duration(seconds: 15));
        } else {
          Fluttertoast.showToast(
              msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor: ColorsJunghanns.red);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "No fue posible obtener las coordenadas del movil",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }

  getDataTransfer({String type = "E"}) async {
    setState(() {
      isLoading = true;
    });
    transfers.clear();
    await getTransfer(type: type).then((answer) {
      log(answer.body.toString());
      setState(() {
        isLoading = false;
      });
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        setState(() {
          answer.body
              .map((e) => transfers.add(TransferModel.fromService(e)))
              .toList();
        });
      }
    });
  }

  setStatus(TransferModel current, String type) async {
    List<ProductModel> dataList = await handler.retrieveProducts();
    var exits = dataList.where((element) =>
        element.idProduct == current.idProduct &&
        element.stock >= current.amount);
    setState(() {
      isLoading = true;
    });
    if (type == "A") {
      if (exits.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "No cuentas con stock suficiente para la solicitud",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        return false;
      }
    }
    await setStatusTransfer({
      "id_solicitud": current.id,
      "estatus": type,
      "lat": currentLocation.latitude.toString(),
      "lon": currentLocation.longitude.toString(),
      "tipo": current.type == "ENVIADA" ? "E" : "R"
    }).then((answer) async {
      setState(() {
        isLoading = false;
      });
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        if (type == "A") {
          await handler.updateProductStock(
              exits.first.stockLocal - current.amount, exits.first.idProduct);
        }
        getDataTransfer(type: itemBar == 1 ? "E" : "R");
        Fluttertoast.showToast(
          msg: "Se actualizo el estatus correctamente",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    });
  }

  Widget touchBar() => Row(
        children: [
          Column(
            children: [
              GestureDetector(
                child: Container(
                  width: (size.width - 20) / 2,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  height: 30,
                  child: Text(
                    "ENVIADAS",
                    textAlign: TextAlign.center,
                    style: itemBar == 1
                        ? TextStyles.blue18SemiBoldIt
                        : TextStyles.grey17_4,
                  ),
                ),
                onTap: () {
                  setState(() {
                    itemBar = 1;
                    getDataTransfer();
                  });
                },
              ),
              Container(
                width: (size.width - 20) / 2,
                height: 3,
                color: itemBar == 1
                    ? ColorsJunghanns.blue
                    : ColorsJunghanns.lightBlue,
              )
            ],
          ),
          Column(
            children: [
              GestureDetector(
                child: Container(
                    width: (size.width - 20) / 2,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    height: 30,
                    child: Text(
                      "RECIBIDAS",
                      textAlign: TextAlign.center,
                      style: itemBar == 2
                          ? TextStyles.blue18SemiBoldIt
                          : TextStyles.grey17_4,
                    )),
                onTap: () {
                  setState(() {
                    itemBar = 2;
                    getDataTransfer(type: "R");
                  });
                },
              ),
              Container(
                width: (size.width - 20) / 2,
                height: 3,
                color: itemBar == 2
                    ? ColorsJunghanns.blue
                    : ColorsJunghanns.lightBlue,
              )
            ],
          ),
        ],
      );
  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    });
    return Scaffold(
        appBar: AppBar(
            backgroundColor: ColorsJunghanns.whiteJ,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: ColorsJunghanns.whiteJ,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.dark),
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorsJunghanns.blue,
                ))),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: RefreshIndicator(
                    onRefresh: ()=>getDataTransfer(type: itemBar==2?"R":"E"),
                    child: 
              SingleChildScrollView(
                child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  provider.connectionStatus == 4? const WithoutInternet():provider.isNeedAsync?const NeedAsync():Container(),
                  touchBar(),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                      visible: itemBar == 1,
                      child: ButtonJunghanns(
                          fun: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      const TransferNew())).then((value) =>
                              getDataTransfer(type: itemBar == 1 ? "E" : "R")),
                          decoration: Decorations.blueBorder30,
                          style: TextStyles.white16SemiBoldIt,
                          label: "Nueva solicitud")),
                  SizedBox(
                    height: size.height * .9,
                    child: Column(
                      children: transfers
                          .map((e) => transferItem(context, setStatus, e))
                          .toList(),
                    ),
                  )
                ],
              ))),
            ),
            Visibility(visible: isLoading, child: const LoadingJunghanns())
          ],
        ));
  }
}
