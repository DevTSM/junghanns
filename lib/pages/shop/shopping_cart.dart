import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/widgets/card/product.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:speed_test_dart/speed_test_dart.dart';

import '../../models/method_payment.dart';

class SecondWayToPay {
  String wayToPay;
  String typeWayToPay;
  double cost;

  SecondWayToPay(
      {required this.wayToPay, required this.typeWayToPay, required this.cost});
}

class ShoppingCart extends StatefulWidget {
  CustomerModel customerCurrent;
  List<AuthorizationModel> authList;
  ShoppingCart(
      {Key? key, required this.customerCurrent, required this.authList})
      : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late Size size;
  late List<ProductModel> productsList, productListOther;
  late bool isLoading, isRange;
  late List<ConfigModel> configList = [];
  late double distance;
  late SecondWayToPay secWayToPay;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController folioC = TextEditingController();
  late bool isRequestFolio = false;
  late String errFolio = "";
  late ProviderJunghanns provider;
  late double latSale, lngSale;
  late bool isOtherProduct;
  late int idLocal;
  @override
  void initState() {
    super.initState();
    productsList = [];
    productListOther = [];
    isLoading = false;
    isRange = false;
    isOtherProduct = false;
    distance = 0;
    secWayToPay = SecondWayToPay(wayToPay: "", typeWayToPay: "", cost: 0);
    latSale = lngSale = 0;
    idLocal=0;
    getDataProducts();
  }

  @override
  void dispose() {
    super.dispose();
    provider.initShopping(CustomerModel.fromState());
  }

  getDataProducts() async {
    Timer(const Duration(milliseconds: 1000), () async {
      provider.initShopping(widget.customerCurrent);
      if (provider.connectionStatus < 4) {
        setState(() {
          isLoading = true;
        });
        await getStockList(prefs.idRouteD).then((answer) {
          setState(() {
            isLoading = false;
          });
          if (answer.error) {
            Fluttertoast.showToast(
              msg: "Sin productos",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
          } else {
            prefs.stock = jsonEncode(answer.body);
            answer.body.map((e) {
              if (widget.authList.isEmpty) {
                productsList.add(ProductModel.fromServiceProduct(e));
              } else {
                if (ProductModel.fromServiceProduct(e).idProduct ==
                    widget.authList.first.product.idProduct) {
                  productsList.add(
                      ProductModel.fromProduct(widget.authList.first.product));
                }
              }
            }).toList();
            //TODO:pruebas
            //     setState(() {
            //   productsList=[ProductModel.fromState(10),ProductModel.fromState(0)];
            //    log("${productsList.length} ---.-----.-------");
            // });
            setState(() {
              productListOther =
                  productsList.where((element) => element.rank == "").toList();
            });
            checkPriceCvsPriceS();
          }
        });
        getDataPayment();
      } else {
        try {
          if (widget.authList.isEmpty) {
            dynamic data = jsonDecode(prefs.stock);
            data.map((e) {
              productsList.add(ProductModel.fromServiceProduct(e));
            }).toList();
            //
            if (productsList.isNotEmpty) {
              setState(() {
                productsList
                    .sort(((a, b) => b.rank.length.compareTo(a.rank.length)));
              });
            }
            checkPriceCvsPriceS();
          } else {
            setState(() {
              productsList
                  .add(ProductModel.fromProduct(widget.authList.first.product));
              isLoading = false;
            });
          }
          setState(() {
            if (widget.customerCurrent.purse > 0) {
              widget.customerCurrent.setPaymentAdd(MethodPayment(
                  wayToPay: "Monedero",
                  typeWayToPay: "M",
                  type: "Monedero",
                  idProductService: -1,
                  description: "",
                  number: -1));
            } else {
              widget.customerCurrent.setPayment(widget.customerCurrent.payment
                  .where((element) => element.typeWayToPay != "M")
                  .toList());
            }
          });
        } catch (e) {
          log("-------- error $e");
        }
      }
    });
  }

  checkPriceCvsPriceS() {
    if (productsList.isNotEmpty) {
      int index = productsList.indexWhere((element) => element.idProduct == 22);
      if (index != -1) {
        log("Index de liquido es: $index");
        if (widget.customerCurrent.priceLiquid < productsList[index].price) {
          productsList[index].price = widget.customerCurrent.priceLiquid;
        }
      }
    }
  }

  getDataPayment() async {
    await getPaymentMethods(widget.customerCurrent.idClient, prefs.idRouteD)
        .then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin formas de pago",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        List<MethodPayment> paymentsList = [];
        //Aqui se valida si existe la autorizacion para como dato para filtrar los metodos de pago
        if (widget.authList.isNotEmpty) {
          switch (widget.authList.first.type) {
            case "C":
              paymentsList.add(MethodPayment(
                  wayToPay: "Credito",
                  typeWayToPay: "C",
                  type: "Atributo",
                  idProductService: -1,
                  description: "",
                  number: -1));
              break;
            case "V":
              answer.body.map((e) {
                MethodPayment method = MethodPayment.fromService(e);
                if (method.idAuth == widget.authList.first.idAuth) {
                  paymentsList.add(method);
                }
              }).toList();
              break;
            default:
          }
        } else {
          //Se agregan todos lo metodos de pago si no hay autorizacion
          answer.body
              .map((e) => paymentsList.add(MethodPayment.fromService(e)))
              .toList();
          //Se agrega metodo de pago "Monedero"
          if (widget.customerCurrent.purse > 0) {
            paymentsList.add(MethodPayment(
                wayToPay: "Monedero",
                typeWayToPay: "M",
                type: "Monedero",
                idProductService: -1,
                description: "",
                number: -1));
          }
        }
        setState(() {
          widget.customerCurrent.setPayment(paymentsList);
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  selectWayToPay() async {
    await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actionScrollController: ScrollController(
                  initialScrollOffset: 1.0, keepScrollOffset: true),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tipo de pago", style: TextStyles.blueJ22Bold),
                      const Text(
                        "Una vez registrado no podrá corregirlo",
                        style: TextStyles.redJ13,
                      )
                    ],
                  ),
                  GestureDetector(
                    child: const Icon(
                      Icons.clear_rounded,
                      color: ColorsJunghanns.red,
                      size: 30,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              actions: widget.customerCurrent.payment.map((item) {
                return showItem(item, FontAwesomeIcons.coins);
              }).toList());
        });
  }

  bool funCheckMethodPayment(MethodPayment methodCurrent) {
    //TODO: esta funcion no es util
    if (methodCurrent.wayToPay == "Monedero") {
      if (provider.basketCurrent.totalPrice > widget.customerCurrent.purse) {
        secWayToPay.wayToPay = "Efectivo";
        secWayToPay.typeWayToPay = "E";
        secWayToPay.cost =
            provider.basketCurrent.totalPrice - widget.customerCurrent.purse;
      }
      return true;
    } else {
      secWayToPay = SecondWayToPay(wayToPay: "", typeWayToPay: "", cost: 0);
      return true;
    }

    // switch (methodCurrent.wayToPay) {
    //   case "Efectivo":
    //     isTrue = true;
    //     secWayToPay = SecondWayToPay(wayToPay: "", typeWayToPay: "", cost: 0);
    //     break;
    //   case "Credito":
    //     isTrue = true;
    //     secWayToPay = SecondWayToPay(wayToPay: "", typeWayToPay: "", cost: 0);
    //     break;
    //   case "Monedero":
    //     if (provider.basketCurrent.totalPrice > widget.customerCurrent.purse) {
    //       secWayToPay.wayToPay = "Efectivo";
    //       secWayToPay.typeWayToPay = "E";
    //       secWayToPay.cost =
    //           provider.basketCurrent.totalPrice - widget.customerCurrent.purse;
    //       isTrue = true;
    //     } else {
    //       isTrue = true;
    //     }
    //     break;
    // }
  }

  showConfirmSale(MethodPayment methodCurrent) {
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
                  secWayToPay.wayToPay.isEmpty
                      ? DefaultTextStyle(
                          style: TextStyles.blueJ22Bold,
                          child: Text("¿Pago en ${methodCurrent.wayToPay} ?"))
                      : textTwoWayToPay(
                          methodCurrent.wayToPay, widget.customerCurrent.purse),
                  DefaultTextStyle(
                      style: TextStyles.blueJ215R,
                      child: const Text(
                        "Deseas registrar la venta de:",
                      )),
                  DefaultTextStyle(
                      style: TextStyles.greenJ24Bold,
                      child: Text(formatMoney
                          .format(provider.basketCurrent.totalPrice))),
                  Material(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: ButtonJunghanns(
                              fun: () async {
                                Navigator.pop(context);
                                //onLoading();
                                setState(() {
                                  isLoading = true;
                                });
                                await setCurrentLocation();
                                if (isRange) {
                                  if (latSale != 0 && lngSale != 0) {
                                    //se valida si es comodato
                                    if (methodCurrent.wayToPay == "Comodato") {
                                      getPhonesCustomer(
                                              widget.customerCurrent.idClient)
                                          .then((answer) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (answer.error) {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Ocurrio un error al obtener lo numeros de telefono",
                                            timeInSecForIosWeb: 4,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP,
                                            webShowClose: true,
                                          );
                                        } else {
                                          widget.customerCurrent.setPhones(
                                              (answer.body["telefonos"] ?? [])
                                                  .map((e) => e["telefono"])
                                                  .toList());
                                          showComodato(methodCurrent);
                                        }
                                      });
                                    } else {
                                      funSale(methodCurrent);
                                    }
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Fluttertoast.showToast(
                                      msg: "Sin coordenadas ",
                                      timeInSecForIosWeb: 16,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      webShowClose: true,
                                    );
                                  }
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Fuera de rango",
                                    timeInSecForIosWeb: 16,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    webShowClose: true,
                                  );
                                }
                              },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Si")),
                      const SizedBox(
                        width: 25,
                      ),
                      Expanded(
                          child: ButtonJunghanns(
                        fun: () {
                          secWayToPay = SecondWayToPay(
                              wayToPay: "", typeWayToPay: "", cost: 0);
                          Navigator.pop(context);
                        },
                        decoration: Decorations.redCard,
                        style: TextStyles.white18SemiBoldIt,
                        label: "No",
                      )),
                    ],
                  ))
                ],
              ),
            ),
          );
        });
  }

  showComodatoVerifi(int id, MethodPayment methodCurrent) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: size.width * .75,
              decoration: Decorations.whiteS1Card,
              child: Material(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      child: const Text("Esperando Autorizacion")),
                  const SizedBox(
                    height: 10,
                  ),
                  const SpinKitCircle(
                    color: ColorsJunghanns.blue,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: ButtonJunghanns(
                              fun: () async {
                                Fluttertoast.showToast(
                                  msg: "Verificando autorización",
                                  timeInSecForIosWeb: 2,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  webShowClose: true,
                                );
                                await getStatusComodato(id).then((answer) {
                                  if (answer.error) {
                                    Fluttertoast.showToast(
                                      msg: "No se pudo verificar",
                                      timeInSecForIosWeb: 2,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      webShowClose: true,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Autorización verificada",
                                      timeInSecForIosWeb: 2,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      webShowClose: true,
                                    );
                                    Navigator.pop(context);
                                    funSale(methodCurrent);
                                  }
                                });
                              },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Verificar")),
                      const SizedBox(
                        width: 25,
                      ),
                      Expanded(
                          child: ButtonJunghanns(
                        fun: () {
                          Navigator.pop(context);
                        },
                        decoration: Decorations.redCard,
                        style: TextStyles.white18SemiBoldIt,
                        label: "Cancelar",
                      )),
                    ],
                  )
                ],
              )),
            ),
          );
        });
  }

  showComodato(MethodPayment methodCurrent) {
    String phoneCurrent = widget.customerCurrent.phones.isNotEmpty
        ? widget.customerCurrent.phones.first
        : "1234";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: size.width * .75,
              decoration: Decorations.whiteS1Card,
              child: Material(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      child: const Text("¿Enviar confirmación a:?")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("* * * * * *"),
                      const SizedBox(
                        width: 10,
                      ),
                      DropdownButton<String>(
                        value: phoneCurrent,
                        icon: const Icon(Icons.arrow_drop_down_sharp),
                        elevation: 5,
                        onChanged: (String? value) {
                          setState(() {
                            phoneCurrent = value!;
                          });
                        },
                        items: (widget.customerCurrent.phones.isNotEmpty
                                ? widget.customerCurrent.phones
                                    .map((e) => e.substring(6, e.length))
                                    .toList()
                                : ["1234"])
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: ButtonJunghanns(
                              fun: () async {
                                Navigator.pop(context);
                                setComodato(widget.customerCurrent.idClient,
                                        latSale, lngSale, phoneCurrent)
                                    .then((answer) {
                                  if (answer.error) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Ocurrio un error al enviar la solicitud",
                                      timeInSecForIosWeb: 2,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      webShowClose: true,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Se envio la solicitud",
                                      timeInSecForIosWeb: 2,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      webShowClose: true,
                                    );
                                    showComodatoVerifi(
                                        answer.body["id_solicitud"] ?? 0,
                                        methodCurrent);
                                  }
                                });
                              },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Enviar")),
                      const SizedBox(
                        width: 25,
                      ),
                      Expanded(
                          child: ButtonJunghanns(
                        fun: () {
                          Navigator.pop(context);
                        },
                        decoration: Decorations.redCard,
                        style: TextStyles.white18SemiBoldIt,
                        label: "Cancelar",
                      )),
                    ],
                  )
                ],
              )),
            ),
          );
        });
  }

  setCurrentLocation() async {
    try {
      Location locationInstance = Location();
      PermissionStatus permission = await locationInstance.hasPermission();
      if (permission == PermissionStatus.granted) {
        provider.permission = true;
        locationInstance.changeSettings(accuracy: LocationAccuracy.high);
        if (await locationInstance.serviceEnabled()) {
          provider.permission = true;
          LocationData currentLocation = await locationInstance
              .getLocation()
              .timeout(const Duration(seconds: 15));
          latSale = currentLocation.latitude!;
          lngSale = currentLocation.longitude!;
          await funCheckDistance(currentLocation);
        } else {
          provider.permission = false;
          Fluttertoast.showToast(
              msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor: ColorsJunghanns.red);
        }
      } else {
        print({"permission": permission.toString()});
        provider.permission = false;
        isRange = false;
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Tiempo de espera superado, vuelve a intentarlo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }

  funCheckDistance(LocationData currentLocation) async {
    try {
      if (provider.connectionStatus < 4) {
        await getConfig(widget.customerCurrent.idClient).then((answer) {
          if (answer.error) {
            Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
          } else {
            for (var item in answer.body) {
              configList.add(ConfigModel.fromService(item));
            }
            setState(() {
              distance = calculateDistance(
                      widget.customerCurrent.lat,
                      widget.customerCurrent.lng,
                      currentLocation.latitude,
                      currentLocation.longitude) *
                  1000;
              isRange = distance <= configList.last.valor;
              log(" distance $distance isRange $isRange");
            });
          }
        });
      } else {
        setState(() {
          distance = calculateDistance(
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng,
                  currentLocation.latitude,
                  currentLocation.longitude) *
              1000;
          isRange = distance <=
              (widget.customerCurrent.configList.isNotEmpty
                  ? widget.customerCurrent.configList.first.valor
                  : 0);
        });
      }
    } catch (e) {
      log("***ERROR -- $e");
      Fluttertoast.showToast(
          msg: "Tiempo de espera superado, vuelve a intentarlo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }

  setLocalSale({bool isConexion=false}) async {
    if (secWayToPay.wayToPay.isEmpty) {
      provider.basketCurrent.waysToPay.add(WayToPay(
          type: widget.customerCurrent.payment.first.typeWayToPay,
          cost: provider.basketCurrent.totalPrice));
    } else {
      provider.basketCurrent.waysToPay.add(WayToPay(
          type: widget.customerCurrent.payment.first.typeWayToPay,
          cost: widget.customerCurrent.purse));
      provider.basketCurrent.waysToPay.add(
          WayToPay(type: secWayToPay.typeWayToPay, cost: secWayToPay.cost));
    }
    List<Map> listSales = [];
    for (var element in provider.basketCurrent.sales) {
      listSales.add({
        "cantidad": element.number,
        "id_producto": element.idProduct,
        "precio_unitario": element.price
      });
    }

    if (widget.customerCurrent.priceS != 0) {
      listSales.add({
        "cantidad": widget.customerCurrent.numberS,
        "id_producto": widget.customerCurrent.idProdServS,
        "precio_unitario": widget.customerCurrent.priceS
      });
    }

    List<Map> listWaysToPay = [];
    for (var ele in provider.basketCurrent.waysToPay) {
      listWaysToPay.add({
        "tipo": ele.type,
        "importe": ele.cost,
      });
    }

    if (widget.authList.isNotEmpty) {
      provider.basketCurrent.idAuth = widget.authList.first.idAuth;
      widget.authList.removeWhere(
          (element) => element.idAuth == provider.basketCurrent.idAuth);
    }
    Map<String, dynamic> data = {
      "idCustomer": provider.basketCurrent.idCustomer,
      "idRoute": provider.basketCurrent.idRoute,
      "lat": "$latSale",
      "lng": "$lngSale",
      "saleItems": jsonEncode(List.from(listSales.toList())),
      "idAuth": provider.basketCurrent.idAuth != -1
          ? provider.basketCurrent.idAuth
          : null,
      "paymentMethod": jsonEncode(listWaysToPay),
      "idOrigin": provider.basketCurrent.idDataOrigin,
      "folio": provider.basketCurrent.folio != -1
          ? provider.basketCurrent.folio
          : null,
      "type": provider.basketCurrent.typeOperation,
      "isUpdate":0
    };
    idLocal= await handler.insertSale(data);
    log("confirmacion de insercion con $idLocal");
    widget.customerCurrent.setType(0);
    var exits = provider.basketCurrent.waysToPay
        .where((element) => element.type == "M");
    if (exits.isNotEmpty) {
      widget.customerCurrent
          .setMoney(widget.customerCurrent.purse - exits.first.cost);
    }
    for (var e in provider.basketCurrent.sales) {
      var exits2 =
          productsList.where((element) => element.idProduct == e.idProduct);
      if (exits2.isNotEmpty) {
        exits2.first.stock -= e.number;
      }
    }
    prefs.stock = jsonEncode(productsList.map((e) => e.getMap()).toList());
    prefs.dataSale = true;
    Fluttertoast.showToast(
      msg: "Guardado solo de forma local",
      timeInSecForIosWeb: 16,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      webShowClose: true,
    );
    if(!isConexion){
    Navigator.pop(context);
    }
  }

  funSale(MethodPayment methodPayment) async {
    int idLocal=0;
    if (provider.connectionStatus < 4) {
      if (secWayToPay.wayToPay.isEmpty) {
        provider.basketCurrent.waysToPay.add(WayToPay(
            type: methodPayment.typeWayToPay,
            cost: provider.basketCurrent.totalPrice));
      } else {
        provider.basketCurrent.waysToPay.add(WayToPay(
            type: methodPayment.typeWayToPay,
            cost: widget.customerCurrent.purse));
        provider.basketCurrent.waysToPay.add(
            WayToPay(type: secWayToPay.typeWayToPay, cost: secWayToPay.cost));
      }
      List<Map> listSales = [];
      for (var element in provider.basketCurrent.sales) {
        listSales.add({
          "cantidad": element.number,
          "id_producto": element.idProduct,
          "precio_unitario": element.price
        });
      }
      if (widget.customerCurrent.priceS != 0) {
        listSales.add({
          "cantidad": widget.customerCurrent.numberS,
          "id_producto": widget.customerCurrent.idProdServS,
          "precio_unitario": widget.customerCurrent.priceS
        });
      }
      List<Map> listWaysToPay = [];
      for (var ele in provider.basketCurrent.waysToPay) {
        listWaysToPay.add({
          "tipo": ele.type,
          "importe": ele.cost,
        });
      }
      if (widget.authList.isNotEmpty) {
        provider.basketCurrent.idAuth = widget.authList.first.idAuth;
        widget.authList.removeWhere(
            (element) => element.idAuth == provider.basketCurrent.idAuth);
      }
      Map<String, dynamic> data = {
        "id_cliente": provider.basketCurrent.idCustomer,
        "id_ruta": provider.basketCurrent.idRoute,
        "latitud": "$latSale",
        "longitud": "$lngSale",
        "venta": List.from(listSales.toList()),
        "id_autorizacion": provider.basketCurrent.idAuth != -1
            ? provider.basketCurrent.idAuth
            : null,
        "formas_de_pago": listWaysToPay,
        "id_data_origen": provider.basketCurrent.idDataOrigin,
        "folio": provider.basketCurrent.folio != -1
            ? provider.basketCurrent.folio
            : null,
        "tipo_operacion": provider.basketCurrent.typeOperation,
        "version": "1.1.4"
      };
      
      // Connection connection=Connection();
      // await connection.init();
      // if(connection.stableConnection){
        await setLocalSale(isConexion: true).then((value) async {
          await postSale(data).then((answer) async {
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
          Navigator.pop(context, true);
        } else {
          Fluttertoast.showToast(
            msg: "Venta realizada con exito",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
          Async async=
          Async(provider: provider);
          async.setDataSales().then((value) => async.setDataStop());
          Navigator.pop(context, true);
        }
      });
        });
    } else {
      setLocalSale();
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.greenJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.greenJ,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light),
        leading: Container(),
        elevation: 0,
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 15),
            child: Text(
              "${urlBase == ipStage ? "Beta " : ""}V$version",
              style: TextStyles.blue18SemiBoldIt,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          header(),
          isLoading ? const LoadingJunghanns() : itemList(),
          Visibility(visible: isRequestFolio, child: requestFolio())
        ],
      ),
      bottomNavigationBar: bottomBar(() {}, 2, isHome: false, context: context),
    );
  }

  Widget itemList() {
    return Container(
      margin: EdgeInsets.only(
          top: widget.customerCurrent.descServiceS != ""
              ? size.height * .20
              : size.height * .22),
      padding: EdgeInsets.only(
          left: 10, right: 10, top: provider.connectionStatus != 4 ? 0 : 20),
      width: double.infinity,
      child: productsList.isEmpty
          ? Center(
              child: Text(
              "Sin productos",
              style: TextStyles.blue18SemiBoldIt,
            ))
          : Column(
              children: [
                Visibility(
                    visible: widget.customerCurrent.descServiceS != "",
                    child: addCharger()),
                isOtherProduct
                    ? Expanded(
                        child: GridView.custom(
                          gridDelegate: SliverWovenGridDelegate.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 13,
                            crossAxisSpacing: 13,
                            pattern: [
                              const WovenGridTile(.85),
                              const WovenGridTile(.85),
                            ],
                          ),
                          childrenDelegate: SliverChildBuilderDelegate(
                              (context, index) => ProductSaleCard(
                                    update: (ProductModel productCurrent,
                                        bool isAdd) {
                                      provider.updateProductShopping(
                                          productCurrent, isAdd);
                                      setState(() {});
                                    },
                                    productCurrent: productListOther[index],
                                  ),
                              childCount: productListOther.length),
                        ),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                        child: Column(
                          children: productsList
                              .where((element) => element.rank != "")
                              .map((e) => ProductSaleCardPriority(
                                  productCurrent: e,
                                  update: (ProductModel productCurrent,
                                      bool isAdd) {
                                    setState(() {
                                      provider.updateProductShopping(
                                          productCurrent, isAdd);
                                    });
                                  }))
                              .toList(),
                        ),
                      )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: 15, right: 15, bottom: 10, top: 10),
                    child: ButtonJunghanns(
                        fun: () {
                          setState(() {
                            isOtherProduct = !isOtherProduct;
                          });
                        },
                        decoration: isOtherProduct
                            ? Decorations.redCardB30
                            : Decorations.blueBorder12,
                        style: TextStyles.white17_5,
                        label:
                            isOtherProduct ? "Regresar" : "Otros Productos")),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                    visible: provider.basketCurrent.sales.isNotEmpty,
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 10),
                        width: double.infinity,
                        height: 40,
                        alignment: Alignment.center,
                        child: ButtonJunghanns(
                          decoration: Decorations.blueBorder12,
                          fun: () {
                            if (widget.customerCurrent.payment.length > 1) {
                              selectWayToPay();
                            } else {
                              //validamos que existan metodos de pago
                              if (widget.customerCurrent.payment.isNotEmpty) {
                                if (funCheckMethodPayment(
                                    widget.customerCurrent.payment.first)) {
                                  if (widget.customerCurrent.payment.first
                                          .wayToPay ==
                                      "Credito") {
                                    setState(() {
                                      //habilitamos el modal para folio
                                      isRequestFolio = true;
                                    });
                                  } else {
                                    showConfirmSale(
                                        widget.customerCurrent.payment.first);
                                  }
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      "No se encontraron metodos de pago ${widget.authList.isNotEmpty ? "para la autorización ${widget.authList.first.idAuth}" : ""}",
                                  timeInSecForIosWeb: 2,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  webShowClose: true,
                                );
                              }
                            }
                          },
                          label: "Terminar venta",
                          style: TextStyles.white17_5,
                        )))
              ],
            ),
    );
  }

  Widget header() {
    return Container(
        height: provider.connectionStatus != 4
            ? size.height * .21
            : size.height * .23,
        color: ColorsJunghanns.green,
        padding: const EdgeInsets.only(right: 15, left: 23, top: 10),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                  visible: provider.connectionStatus == 4,
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const WithoutInternet())),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: ColorsJunghanns.white,
                      )),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 8, top: 10),
                            child: Text(
                              provider.basketCurrent.sales.isNotEmpty
                                  ? (provider.basketCurrent.sales
                                          .map((e) => e.number)
                                          .toList())
                                      .reduce(
                                          (value, element) => value + element)
                                      .toString()
                                  : "0",
                              style: TextStyles.white24SemiBoldIt,
                            ),
                          ),
                          Image.asset(
                            "assets/icons/shoppingIcon.png",
                            width: 60,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        formatMoney.format(provider.basketCurrent.totalPrice),
                        style: TextStyles.white40Bold,
                      )
                    ],
                  )),
                  SizedBox(
                    width: size.width * .1,
                  ),
                ],
              ),
            ]));
  }

  Widget addCharger() {
    return Container(
      width: double.infinity,
      decoration: Decorations.whiteSblackCard,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(children: [
        Row(children: [
          Image.asset(
            "assets/icons/exclamation.png",
            width: size.width * 0.1,
          ),
          Container(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Servicio especial", style: TextStyles.blueJ20BoldIt),
                    widget.customerCurrent.priceS != 0
                        ? Text(
                            "Cargo extra",
                            style: TextStyles.blueJ18It,
                          )
                        : Container()
                  ])),
          Expanded(
              child: Text(
            widget.customerCurrent.priceS != 0
                ? formatMoney.format(widget.customerCurrent.priceS)
                : "",
            style: TextStyles.blueJ25Bold,
            textAlign: TextAlign.end,
          ))
        ]),
        Container(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.customerCurrent.descServiceS,
              style: TextStyles.grey17Itw,
              textAlign: TextAlign.justify,
            ))
      ]),
    );
  }

  Widget requestFolio() {
    return Container(
      alignment: Alignment.center,
      color: Colors.black.withOpacity(0.3),
      child: Container(
          padding: const EdgeInsets.all(18),
          width: size.width * .75,
          decoration: Decorations.whiteS1Card,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Title
                  titleFolio(),
                  //Field
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        folioField(),
                        Container(
                            padding: const EdgeInsets.only(
                                top: 4, left: 10, bottom: 8),
                            child: Text(
                              errFolio,
                              style: TextStyles.redJ13N,
                            )),
                      ]),
                  //Buttom Validate
                  buttomFolio()
                ],
              ),
            ],
          )),
    );
  }

  Widget titleFolio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: size.width * 0.1),
        Container(
            alignment: Alignment.center,
            child: DefaultTextStyle(
                style: TextStyles.blueJ22Bold,
                child: const Text("Ingresa folio"))),
        GestureDetector(
          child: const Icon(
            FontAwesomeIcons.times,
            size: 24,
            color: ColorsJunghanns.grey,
          ),
          onTap: () {
            setState(() {
              isRequestFolio = false;
            });
          },
        )
      ],
    );
  }

  Widget folioField() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      child: TextFormField(
          controller: folioC,
          keyboardType: TextInputType.number,
          style: TextStyles.blueJ20Bold,
          decoration: InputDecoration(
            hintText: "Folio",
            hintStyle: TextStyles.grey20Itw,
            filled: true,
            fillColor: ColorsJunghanns.whiteJ,
            contentPadding: const EdgeInsets.only(left: 24),
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderSide: errFolio == ""
                  ? const BorderSide(width: 1, color: ColorsJunghanns.blueJ3)
                  : const BorderSide(width: 1, color: Colors.red),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(width: 2, color: ColorsJunghanns.blueJ),
              borderRadius: BorderRadius.circular(10),
            ),
          )),
    );
  }

  Widget buttomFolio() {
    return GestureDetector(
      onTap: () async {
        if (folioC.text.isNotEmpty) {
          setState(() {
            isLoading = true;
            isRequestFolio = false;
          });
          await getFolio(folioC.text,
                  provider.basketCurrent.sales.first.idProduct, prefs.idRouteD)
              .then((answer) {
            if (answer.error) {
              Fluttertoast.showToast(
                msg: answer.message,
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
              setState(() {
                isLoading = false;
                errFolio = "* Error";
                isRequestFolio = true;
              });
            } else {
              bool available =
                  answer.body["estatus"] == "available" ? true : false;
              if (available) {
                log("Folio disponible");
                provider.basketCurrent.folio = int.parse(folioC.text);
                MethodPayment met = widget.customerCurrent.payment
                    .firstWhere(((element) => element.wayToPay == "Credito"));
                setState(() {
                  isLoading = false;
                });
                showConfirmSale(met);
              } else {
                log("Folio no disponible");
                setState(() {
                  isLoading = false;
                  isRequestFolio = true;
                  errFolio = "* Folio no disponible";
                });
              }
            }
          });
        } else {
          setState(() {
            errFolio = "* Ingresa algún folio";
          });
        }
      },
      child: Container(
          alignment: Alignment.center,
          width: size.width * 0.3,
          height: size.width * 0.12,
          decoration: Decorations.blueBorder12,
          child: DefaultTextStyle(
              style: TextStyles.white18SemiBold, child: const Text("Validar"))),
    );
  }

  Widget extraCharge() {
    return Container(
        width: size.width,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(6),
        decoration: Decorations.blueCard,
        child: Column(
          children: [
            Text(
              widget.customerCurrent.descServiceS,
              style: TextStyles.blueJ20BoldIt,
              textAlign: TextAlign.center,
            ),
            widget.customerCurrent.priceS != 0
                ? Container(
                    decoration: Decorations.white2Card,
                    padding: const EdgeInsets.fromLTRB(45, 5, 45, 5),
                    margin: const EdgeInsets.only(top: 4),
                    child: Text(
                      formatMoney.format((widget.customerCurrent.priceS *
                          widget.customerCurrent.numberS)),
                      style: TextStyles.blueJ20BoldIt,
                    ),
                  )
                : Container()
          ],
        ));
  }

  Widget showItem(MethodPayment methodCurrent, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (funCheckMethodPayment(methodCurrent)) {
          if (methodCurrent.wayToPay == "Credito") {
            log("Pedir Folio");
            setState(() {
              isRequestFolio = true;
            });
          } else {
            showConfirmSale(methodCurrent);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 35, top: 8, bottom: 8),
        child: Row(children: [
          Container(
              decoration: Decorations.blueJ2Card,
              padding:
                  const EdgeInsets.only(right: 10, left: 7, top: 5, bottom: 7),
              margin: const EdgeInsets.only(right: 15),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              )),
          DefaultTextStyle(
              style: TextStyles.blueJ220Bold,
              child: Text(
                methodCurrent.wayToPay,
              )),
        ]),
      ),
    );
  }

  Widget textTwoWayToPay(String wayToPay, double cost) {
    return Column(children: [
      DefaultTextStyle(
          style: TextStyles.blueJ22Bold, child: const Text("Pago en ")),
      DefaultTextStyle(
          style: TextStyles.blueJ18Bold,
          child: Text("$wayToPay - ${formatMoney.format(cost)}")),
      DefaultTextStyle(
          style: TextStyles.blueJ18Bold,
          child: Text(
              "${secWayToPay.wayToPay} - ${formatMoney.format(secWayToPay.cost)}")),
    ]);
  }
}
