import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/yes_not.dart';
import 'package:junghanns/components/select.dart';
import 'package:junghanns/components/textfield/text_field.text.dart';
import 'package:junghanns/models/transfer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:location/location.dart';

class TransferNew extends StatefulWidget {
  const TransferNew({super.key});

  @override
  State<StatefulWidget> createState() => _TransferNewState();
}

class _TransferNewState extends State<TransferNew> {
  late List<Map<String, dynamic>> products, routes;
  late Map<String, dynamic> product, route;
  late LocationData currentLocation;
  late TextEditingController count, descripcion;

  late Size size;
  late int amount;
  late bool isLoading;
  @override
  void initState() {
    super.initState();
    products = [];
    routes = [];
    product = {};
    route = {};
    currentLocation = LocationData.fromMap({});
    count = TextEditingController();
    descripcion = TextEditingController();
    amount = 0;
    isLoading = true;
    getDataSolicitud();
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

  getDataSolicitud() async {
    setState(() {
      isLoading = true;
    });
    await getProducts().then((answer) {
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
          products = List.from(answer.body);
          product = products.isNotEmpty
              ? products.first
              : {
                  "products": {"id": []}
                };
        });
      }
    });
    setState(() {
      isLoading = true;
    });
    await getRoutes().then((answer) {
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
          routes = List.from(answer.body);
          routes.removeWhere((element) => element["id"]==prefs.idRouteD);
          route = routes.isNotEmpty ? routes.first : {"id": 0};
        });
      }
    });
  }

  addFunction({bool isAdd = true}) {
    if (isAdd) {
      setState(() {
        amount++;
        count.text = amount.toString();
      });
    } else {
      if (amount > 0) {
        setState(() {
          amount--;
          count.text = amount.toString();
        });
      }
    }
  }

  setNewTransfer() async {
    setState(() {
      isLoading=true;
    });
    await setCurrentLocation();
    if (product["productos"] != null) {
      if (product["productos"]["id"] != null) {
        if (product["productos"]["id"].length > 1) {
          int cont = 0;
          for (var e in product["productos"]["id"]) {
            await setTransferNew({
              "id_producto": e,
              "cantidad": amount,
              "id_ruta_entrega": route["id"],
              "lat": currentLocation.latitude.toString(),
              "lon": currentLocation.longitude.toString(),
              "observacion": descripcion.text
            }).then((value) => value.error ? cont : cont++);
          }
          setState(() {
      isLoading=false;
    });
    if(cont==product["productos"]["id"].length){
          Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Se proceso la solicitud exitosamente",
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
    }
        } else {
          await setTransferNew({
            "id_producto": product["productos"]["id"][0],
            "cantidad": amount,
            "id_ruta_entrega": route["id"],
            "lat": currentLocation.latitude.toString(),
            "lon": currentLocation.longitude.toString(),
            "observacion": descripcion.text
          }).then((answer) {
            if (answer.error) {
              Fluttertoast.showToast(
                msg: answer.message,
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            } else {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Se proceso la solicitud exitosamente",
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            }
          });
        }
      }
    }
    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
      body: 
      Stack(
        children: [
          Container(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DefaultTextStyle(
                    style: TextStyles.blueJ18It,
                    textAlign: TextAlign.center,
                    child: const Text("Selecciona la cantidad y el producto")),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //BOTON DE MENOS
                        GestureDetector(
                            child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(22, 12, 22, 12),
                                child: const Icon(
                                  FontAwesomeIcons.minus,
                                  size: 35,
                                  color: ColorsJunghanns.red,
                                )),
                            onTap: () => addFunction(isAdd: false)),

                        //CANTIDAD
                        Expanded(
                            child: textField2((String value) {
                          setState(() {
                            if (value != "") {
                              int? number = int.tryParse(value);
                              amount = number!;
                            } else {
                              amount = 0;
                            }
                          });
                        }, count, "", type: TextInputType.number)),

                        //BOTON DE MAS
                        GestureDetector(
                            child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(22, 12, 22, 12),
                                child: const Icon(
                                  FontAwesomeIcons.plus,
                                  size: 35,
                                  color: ColorsJunghanns.greenJ,
                                )),
                            onTap: () => addFunction())
                      ],
                    )),
                Visibility(
                    visible: products.isNotEmpty,
                    child: selectMap(context, (Map<String, dynamic>? value) {
                      setState(() {
                        product = value!;
                      });
                    }, products, product)),
                const SizedBox(
                  height: 10,
                ),
                DefaultTextStyle(
                    style: TextStyles.blueJ18It,
                    textAlign: TextAlign.center,
                    child: const Text("Solicitar a :")),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                    visible: routes.isNotEmpty,
                    child: selectMap(context, (Map<String, dynamic>? value) {
                      setState(() {
                        route = value!;
                      });
                    }, routes, route)),
                const SizedBox(
                  height: 10,
                ),
                DefaultTextStyle(
                    style: TextStyles.blueJ18It,
                    textAlign: TextAlign.center,
                    child: const Text("Observaciones:")),
                const SizedBox(
                  height: 10,
                ),
                textField(
                    descripcion,
                    "",
                    Container(
                      width: 1,
                      height: 1,
                      color: Colors.transparent,
                    ),
                    false,
                    max: 75,
                    decoration: Decorations.blueCard),
                const SizedBox(
                  height: 15,
                ),
                ButtonJunghanns(
                    fun: amount > 0?() => showYesNot(
                        context,setNewTransfer
                            ,
                        "¿Solicitar $amount ${product["descripcion"]} a ${route["descripcion"]} ?",
                        true): () => Fluttertoast.showToast(
                                  msg: "La cantidad debe ser mayor a 0",
                                  timeInSecForIosWeb: 2,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  webShowClose: true,
                                ),
                    decoration: Decorations.blueBorder12,
                    style: TextStyles.white18SemiBoldIt,
                    label: "Aceptar"),
              ],
            ),
          )),
          Visibility(
        visible: isLoading,
        child: const LoadingJunghanns())
        ],
      )
    );
  }
}
