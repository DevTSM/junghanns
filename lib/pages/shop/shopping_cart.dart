import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/show_brand.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/folio.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/product.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../models/method_payment.dart';

class SecondWayToPay {
  String wayToPay;
  String typeWayToPay;
  double cost;

  SecondWayToPay(
      {required this.wayToPay, required this.typeWayToPay, required this.cost});
}

class ShoppingCart extends StatefulWidget {
  final CustomerModel customerCurrent;
  final List<AuthorizationModel> authList;
  final int index;
  const ShoppingCart(
      {Key? key,
      required this.customerCurrent,
      required this.authList,
      this.index = 2})
      : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late ProviderJunghanns provider;
  late List<ProductModel> productsList, productListOther;
  late List<MethodPayment> paymentsRecovery;
  late List<ConfigModel> configList = [];
  late List<FolioModel> folios = [];
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController folioC = TextEditingController();
  late Size size;
  late SecondWayToPay secWayToPay; //se tiene que remover posteriormente
  late String errFolio = "";
  late double latSale, lngSale;
  late double distance;
  late bool isLoading, isRange;
  late bool isRequestFolio = false;
  late bool isOtherProduct;

  @override
  void initState() {
    super.initState();
    productsList = [];
    productListOther = [];
    paymentsRecovery = [];
    folios = [];
    secWayToPay = SecondWayToPay(wayToPay: "", typeWayToPay: "", cost: 0);
    distance = 0;
    latSale = 0;
    lngSale = 0;
    isLoading = false;
    isRange = false;
    isOtherProduct = false;
    getProductLocal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProductLocal() async {
    Timer(const Duration(milliseconds: 1000), () async {
      provider.initShopping(widget.customerCurrent,
          auth: widget.authList.isNotEmpty
              ? widget.authList.first
              : null);
      List<ProductModel> dataList = await handler.retrieveProducts();
      dataList.map((e) {
        if (provider.basketCurrent.authCurrent.idAuth == 0) {
          
          if (e.stock > 0) {
            setState(() {
              productsList.add(e);
            });
          }
        } else {
          
          if (e.idProduct ==
             provider.basketCurrent.authCurrent.product.idProduct) {
            setState(() {
              ProductModel product =
                  ProductModel.fromProduct(provider.basketCurrent.authCurrent.product);
              product.setStock(
                  product.stock <= e.stock
                      ? product.stock
                      : e.stock,
                  e.stock);
                  log("========> Producto ${product.getMap()}");
              //validamos que la autorización sea de precio especial para asignar el precio correspondiente
              //TODO: quitar esta validacion
              // if (provider.basketCurrent.authCurrent.authText == "PRECIO ESPECIAL") {
              //     product.setPrice = widget.customerCurrent.priceLiquid;
              // }
                productsList.add(product);
            });
          }
        }
      }).toList();
      var priceEspecialList=productsList.where((e)=>e.idProduct==22);
      if(priceEspecialList.isNotEmpty&& widget.customerCurrent.isAuthPrice==0&&provider.basketCurrent.authCurrent.idAuth == 0){
        log("========> Producto ${widget.customerCurrent.isAuthPrice}");
        setState(() {
          priceEspecialList.first.setPrice=widget.customerCurrent.priceLiquid;
        });
      }
      setState(() {
        var exits = productsList.where((element) => element.rank == "");
        productListOther = exits.toList();
        isOtherProduct =
            (productsList.where((element) => element.rank != "").isEmpty);
      });
      getDataPayment();
      folios = await handler.retrieveFolios();
    });
  }

  checkPriceCvsPriceS() {
    if (productsList.isNotEmpty) {
      int index = productsList.indexWhere((element) => element.idProduct == 22);
      if (index != -1) {
        log("Index de liquido es: $index");
        log("Price liquid: ${widget.customerCurrent.priceLiquid}");
        if (widget.customerCurrent.priceLiquid < productsList[index].price) {
          productsList[index].price = widget.customerCurrent.priceLiquid;
        }
      }
    }
  }

  getDataPayment() async {
    List<MethodPayment> paymentsList = [];
    List<MethodPayment> paymentsListT = [];
    await getPaymentMethods(widget.customerCurrent.idClient, prefs.idRouteD)
        .then((answer) {
      if (!answer.error) {
        answer.body.map((e) {
          paymentsListT.add(MethodPayment.fromService(e));
        }).toList();
      } else {
        Fluttertoast.showToast(
            msg: "Conexion inestable con el back",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
            backgroundColor: ColorsJunghanns.red);
      }
    });
    if (paymentsListT.isNotEmpty) {
      widget.customerCurrent.setPayment(paymentsListT);
    }
    //respladamos la lista de formas de pago
    paymentsRecovery = widget.customerCurrent.payment;
    log("=====> ${paymentsRecovery.length}");

    if (provider.basketCurrent.authCurrent.idAuth != 0) {
      //Aqui se valida si existe la autorizacion para filtrar los metodos de pago
      widget.customerCurrent.payment.map((e) {
        if (e.idAuth == provider.basketCurrent.authCurrent.idAuth) {
          paymentsList.add(e);
        }
      }).toList();
    }
    if (paymentsList.isEmpty) {
      //Se agregan todos lo metodos de pago si no hay autorizacion
      widget.customerCurrent.payment
          .map((e) => e.wayToPay != "Monedero" ? paymentsList.add(e) : null)
          .toList();
      //Se agrega metodo de pago "Monedero"
      if (widget.customerCurrent.purse > 0 &&
          widget.customerCurrent.payment
              .where((element) => element.wayToPay == "Monedero")
              .isEmpty) {
        paymentsList.add(MethodPayment(
            wayToPay: "Monedero",
            type: "Monedero",
            idProductService: -1,
            description: "",
            number: -1));
      }
    }
    setState(() {
      widget.customerCurrent.setPayment(paymentsList);
      isLoading = false;
    });
  }

  selectPayment() async {
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
    //TODO: esta funcion no es util ya que esta mal implementado el segundo metodo de pago
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
                  Visibility(
                      visible: provider.basketCurrent.authCurrent.authText
                              .toUpperCase() ==
                          "GARRAFON A LA PAR",
                      child: DefaultTextStyle(
                          style: TextStyles.blueJ215R,
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "Marca de garrafon: ${provider.basketCurrent.brandJug["descripcion"] ?? "No se proporciono"} ",
                                style: TextStyles.blueJ215R),
                            // TextSpan(
                            //   text: "Editar",
                            //   style: TextStyles.blue13SemiBoldUnderline,
                            //   recognizer: TapGestureRecognizer()
                            //     ..onTap = () {
                            //       Navigator.pop(context);
                            //       showBrand(context);
                            //     },
                            // )
                          ])))),
                  Visibility(
                      visible:
                          methodCurrent.wayToPay.toUpperCase() == "PRESTAMO",
                      child: DefaultTextStyle(
                          style: TextStyles.blueJ215R,
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "Devolución: ${DateFormat('dd/MM/yyyy').format(provider.basketCurrent.datePrestamo)} ",
                                style: TextStyles.blueJ215R),
                            TextSpan(
                              text: "Editar",
                              style: TextStyles.blue13SemiBoldUnderline,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pop(context);
                                  _selectDate(context);
                                },
                            )
                          ])))),
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
                                      await getPhonesCustomer(
                                              widget.customerCurrent.idClient)
                                          .then((answer) async {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (answer.error) {
                                          Fluttertoast.showToast(
                                              msg: answer.status == 1002
                                                  ? 'No es posible la autorización de comodatos sin red, revisa tu conexión de internet'
                                                  : 'Ocurrio un error al obtener lo numeros de telefono',
                                              timeInSecForIosWeb: 2,
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.TOP,
                                              webShowClose: true);
                                        } else {
                                          List<String> phones = [];
                                          (answer.body["telefonos"] ?? [])
                                              .map((e) {
                                            if ((e["tipo"] ?? "") == "MOVIL") {
                                              phones.add(
                                                  e["telefono"].toString());
                                            }
                                          }).toList();
                                          widget.customerCurrent
                                              .setPhones(phones);
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
                              fun: provider.isProcessValidate
                                  ? () {}
                                  : () async {
                                      Fluttertoast.showToast(
                                        msg: "Verificando autorización ......",
                                        timeInSecForIosWeb: 2,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.TOP,
                                        webShowClose: true,
                                      );
                                      await getStatusComodato(id)
                                          .then((answer) {
                                        if (answer.error) {
                                          Fluttertoast.showToast(
                                            msg: "No se pudo verificar",
                                            timeInSecForIosWeb: 2,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP,
                                            webShowClose: true,
                                          );
                                        } else {
                                          //preguntar por el provider
                                          if (!provider.isProcessValidate) {
                                            if (answer.body["estatus"] == "A") {
                                              Fluttertoast.showToast(
                                                msg: "Autorización verificada",
                                                timeInSecForIosWeb: 2,
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.TOP,
                                                webShowClose: true,
                                              );
                                              Navigator.pop(context);
                                              provider.basketCurrent.folio =
                                                  int.parse(
                                                      answer.body["folio"] ??
                                                          "-1");
                                              funSale(methodCurrent);
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: "Aun no se ha verificado.",
                                                timeInSecForIosWeb: 2,
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.TOP,
                                                webShowClose: true,
                                              );
                                            }
                                          }
                                        }
                                      });
                                    },
                              decoration: provider.isProcessValidate
                                  ? Decorations.blueOpacity(.6, 12)
                                  : Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: provider.isProcessValidate
                                  ? "Validando..."
                                  : "Verificar")),
                      // const SizedBox(
                      //   width: 25,
                      // ),
                      // Expanded(
                      //     child: ButtonJunghanns(
                      //   fun: () {
                      //     Navigator.pop(context);
                      //   },
                      //   decoration: Decorations.redCard,
                      //   style: TextStyles.white18SemiBoldIt,
                      //   label: "Cancelar",
                      // )),
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
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("* * * * * *"),
                      const SizedBox(
                        width: 10,
                      ),
                      widget.customerCurrent.phones.length > 1
                          ? DropdownButton<String>(
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
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                          : widget.customerCurrent.phones.isNotEmpty
                              ? Text(widget.customerCurrent.phones.first
                                  .substring(
                                      6,
                                      widget
                                          .customerCurrent.phones.first.length))
                              : const Text("Sin numeros registrados")
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: ButtonJunghanns(
                              fun: () async {
                                Navigator.pop(context);
                                DeviceInfoPlugin deviceInfoPlugin =
                                    DeviceInfoPlugin();
                                AndroidDeviceInfo build =
                                    await deviceInfoPlugin.androidInfo;
                                await setComodato(
                                        build,
                                        widget.customerCurrent.idClient,
                                        latSale,
                                        lngSale,
                                        provider.basketCurrent.sales.first
                                            .idProduct,
                                        provider
                                            .basketCurrent.sales.first.number,
                                        widget.authList.first.idAuth,
                                        phoneCurrent)
                                    .then((answer) {
                                  if (answer.error) {
                                    Fluttertoast.showToast(
                                      msg: answer.message,
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
                                    provider.isProcessValidate = false;
                                    provider.updateComodato =
                                        (Map<String, dynamic> data) {
                                      if ((data["validado"] ?? false) == true) {
                                        Fluttertoast.showToast(
                                          msg: "Autorización verificada",
                                          timeInSecForIosWeb: 2,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          webShowClose: true,
                                        );
                                        Navigator.pop(context);
                                        funSale(methodCurrent);
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Aun no se ha verificado.",
                                          timeInSecForIosWeb: 2,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          webShowClose: true,
                                        );
                                      }
                                    };
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: provider.basketCurrent.datePrestamo,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime(2038));
    if (picked != null) {
      provider.basketCurrent.datePrestamo = picked;
    }
    showConfirmSale(widget.customerCurrent.payment.first);
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
          msg: "Dispositivo sin coordenadas",
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
            configList.addAll(widget.customerCurrent.configList);
          } else {
            for (var item in answer.body) {
              configList.add(ConfigModel.fromService(item));
            }
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

  caseSale() async {
    if (widget.customerCurrent.payment.length > 1) {
      //si hay mas de un metodo agregamos select
      selectPayment();
    } else {
      if (widget.customerCurrent.payment.isNotEmpty) {
        //validamos que existan metodos de pago
        if (funCheckMethodPayment(widget.customerCurrent.payment.first)) {
          if (widget.customerCurrent.payment.first.getIsFolio()) {
            //habilitamos el modal para folio
            setState(() {
              isRequestFolio = true;
            });
          } else {
            if (provider.basketCurrent.authCurrent.authText.toUpperCase() ==
                "GARRAFON A LA PAR") {
              List<Map<String, dynamic>> list = List.from(
                  jsonDecode(prefs.brands != "" ? prefs.brands : "[]"));
              if (list.isNotEmpty) {
                provider.basketCurrent.brandJug = list.first;
                showBrand(
                    context,
                    () => showConfirmSale(widget.customerCurrent.payment.first),
                    provider,
                    list);
              } else {
                Fluttertoast.showToast(
                  msg: "No se encontraron marcas de garrafon",
                  timeInSecForIosWeb: 2,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  webShowClose: true,
                );
                provider.basketCurrent.brandJug = {
                  "id": 0,
                  "descripcion": "Sin marca"
                };
                showConfirmSale(widget.customerCurrent.payment.first);
              }
            } else {
              showConfirmSale(widget.customerCurrent.payment.first);
            }
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
  }

  funSale(MethodPayment methodPayment) async {
    setState(() {
      isLoading = true;
    });
    //validacion de segundo metodo de pago
    if (secWayToPay.wayToPay.isEmpty) {
      provider.basketCurrent.waysToPay.add(WayToPay(
          type: methodPayment.wayToPay,
          cost: provider.basketCurrent.totalPrice));
    } else {
      provider.basketCurrent.waysToPay.add(WayToPay(
          type: methodPayment.type, cost: widget.customerCurrent.purse));
      provider.basketCurrent.waysToPay.add(
          WayToPay(type: secWayToPay.typeWayToPay, cost: secWayToPay.cost));
    }
    //agregamos los productos
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
    List<Map<String, dynamic>> listWaysToPay = [];
    for (var ele in provider.basketCurrent.waysToPay) {
      listWaysToPay.add({
        "tipo": ele.type,
        "importe": ele.cost,
      });
    }
    //se validan las autorizaciones
    if (widget.authList.isNotEmpty) {
      provider.basketCurrent.idAuth = widget.authList.first.idAuth;
      widget.authList.removeWhere(
          (element) => element.idAuth == provider.basketCurrent.idAuth);
    }
    //se crea la data default
    Map<String, dynamic> data = {};
    data["id_cliente"] = provider.basketCurrent.idCustomer;
    data["id_ruta"] = provider.basketCurrent.idRoute;
    data["latitud"] = "$latSale";
    data["longitud"] = "$lngSale";
    data["venta"] = List.from(listSales.toList());
    data["formas_de_pago"] = listWaysToPay;
    data["id_data_origen"] = provider.basketCurrent.idDataOrigin;
    data["tipo_operacion"] = provider.basketCurrent.typeOperation;
    //se valida si se agrega el campo id marca de garrafon (prestamo)
    if (provider.basketCurrent.brandJug["id"] != null) {
      data["id_marca_garrafon"] = provider.basketCurrent.brandJug["id"];
    }
    //se valida si se agrega el campo autorizacion
    if (provider.basketCurrent.idAuth != -1) {
      data["id_autorizacion"] = provider.basketCurrent.idAuth;
    }
    //se valida si se agrega el campo folio
    if (provider.basketCurrent.folio != -1) {
      data["folio"] = provider.basketCurrent.folio;
    }
    data["fecha_entrega"] =
        DateFormat('yyyy/MM/dd').format(provider.basketCurrent.datePrestamo);
    //se crea la data local
    Map<String, dynamic> dataLocal = {
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
      "isUpdate": 0,
      "fecha": DateTime.now().toString(),
      "fecha_entrega": provider.basketCurrent.idAuth != -1
          ? DateFormat('yyyy/MM/dd').format(provider.basketCurrent.datePrestamo)
          : null,
      "id_marca_garrafon": provider.basketCurrent.brandJug["id"]
    };
    //se inserta la venta
    int id = await handler.insertSale(dataLocal);
    // se asigna el id de operacion local para evitar duplicidad
    data["id_local"] = id;
    log("venta enviada con :::::::: $data");
    //se intenta enviar la venta
    await postSale(data).then((answer) async {
      setState(() {
        isLoading = false;
      });
      //en caso de que la venta se registre con exito
      if (!answer.error) {
        //se deshabilita el folio
        if (provider.basketCurrent.folio != -1) {
          log("desabilitando folio ${provider.basketCurrent.folio}");
          var exits = folios.where(
              (element) => element.number == provider.basketCurrent.folio);
          if (exits.isNotEmpty) {
            log("desabilitando folio ${exits.first.status}");
            exits.first.setStatus = 0;
            await handler.updateFolio(exits.first);
          }
        }
        //se actualuza el stock
        for (var e in provider.basketCurrent.sales) {
          await handler.updateProductStock(
              (e.stockLocal - e.number), e.idProduct);
        }
        //se elimina la autorizacion del cliente en caso de existir
        if (provider.basketCurrent.idAuth != -1) {
          widget.customerCurrent.delete(provider.basketCurrent.idAuth);
        }
        //se descuenta de monedero en caso de ser usado
        if (provider.basketCurrent.waysToPay
            .where((element) => element.type == "Monedero")
            .isNotEmpty) {
          widget.customerCurrent.setMoney(
              (widget.customerCurrent.purse -
                          ((provider.basketCurrent.sales
                                  .map((element) =>
                                      element.price * element.number)
                                  .toList())
                              .reduce((value, element) => value + element))) >=
                      0
                  ? (widget.customerCurrent.purse -
                      ((provider.basketCurrent.sales
                              .map((element) => element.price * element.number)
                              .toList())
                          .reduce((value, element) => value + element)))
                  : 0,
              isOffline: true,
              type: 0);
        }
        //se agrega al historial
        widget.customerCurrent.addHistory({
          'fecha': DateTime.now().toString(),
          'tipo': "VENTA",
          'descripcion':
              "${provider.basketCurrent.sales.first.idProduct} - ${provider.basketCurrent.sales.first.description}",
          'importe': provider.basketCurrent.sales
              .map((e) => e.number * e.price)
              .toList()
              .reduce((value, element) => value + element),
          'cantidad': provider.basketCurrent.sales
              .map((e) => e.number)
              .toList()
              .reduce((value, element) => value + element)
        });
        //validamos la restauracion de los metodos de pago
        if (provider.basketCurrent.idAuth != 0) {
          listWaysToPay
              .map((e) => paymentsRecovery.removeWhere((element) =>
                  element.wayToPay.toUpperCase() ==
                      e["tipo"].toString().toUpperCase() &&
                  e["tipo"].toString().toUpperCase() != "EFECTIVO"))
              .toList();
          log("=====> ${paymentsRecovery.length}");
          widget.customerCurrent.setPayment(paymentsRecovery);
        }
        //se actualiza el cliente a atendidos
        widget.customerCurrent.setType(7);
        //se actualiza la venta
        await handler.updateSale(
            {'isUpdate': 1, 'fecha': DateTime.now().toString()}, id);
        //se regresa al dashboard
        //Navigator.pop(context, true);

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Venta registrada con exito',
          dismissOnTouchOutside: false,
          btnOkText: "Aceptar",
          btnOkOnPress: () => Navigator.pop(context),
        ).show();
      } else {
        //se valida si el error es por falta de red
        if (answer.status == 1002) {
          //se habilita el label de sincronizacion necesaria
          provider.isNeedAsync = true;
          //se actualuza el stock
          for (var e in provider.basketCurrent.sales) {
            await handler.updateProductStock(
                (e.stockLocal - e.number), e.idProduct);
          }
          //se elimina la autorizacion del cliente en caso de existir
          if (provider.basketCurrent.idAuth != -1) {
            widget.customerCurrent.delete(provider.basketCurrent.idAuth);
          }
          //se descuenta de monedero en caso de ser usado
          if (provider.basketCurrent.waysToPay
              .where((element) => element.type == "Monedero")
              .isNotEmpty) {
            widget.customerCurrent.setMoney(
                (widget.customerCurrent.purse -
                            ((provider.basketCurrent.sales
                                    .map((element) =>
                                        element.price * element.number)
                                    .toList())
                                .reduce(
                                    (value, element) => value + element))) >=
                        0
                    ? (widget.customerCurrent.purse -
                        ((provider.basketCurrent.sales
                                .map(
                                    (element) => element.price * element.number)
                                .toList())
                            .reduce((value, element) => value + element)))
                    : 0,
                isOffline: true,
                type: 0);
          }
          //se agrega al historial
          widget.customerCurrent.addHistory({
            'fecha': DateTime.now().toString(),
            'tipo': "VENTA",
            'descripcion':
                "${provider.basketCurrent.sales.first.idProduct} - ${provider.basketCurrent.sales.first.description}",
            'importe': provider.basketCurrent.sales
                .map((e) => e.number * e.price)
                .toList()
                .reduce((value, element) => value + element),
            'cantidad': provider.basketCurrent.sales
                .map((e) => e.number)
                .toList()
                .reduce((value, element) => value + element)
          });
          //validamos la restauracion de los metodos de pago
          if (provider.basketCurrent.idAuth != 0) {
            listWaysToPay
                .map((e) => paymentsRecovery.removeWhere((element) =>
                    element.wayToPay.toUpperCase() ==
                        e["tipo"].toString().toUpperCase() &&
                    e["tipo"].toString().toUpperCase() != "EFECTIVO"))
                .toList();
            widget.customerCurrent.setPayment(paymentsRecovery);
          }
          //se deshabilita el folio
          if (provider.basketCurrent.folio != -1) {
            var exits = folios.where(
                (element) => element.number == provider.basketCurrent.folio);
            if (exits.isNotEmpty) {
              exits.first.setStatus = 0;
              await handler.updateFolio(exits.first);
            }
          }
          //se actualiza el cliente a atendidos
          widget.customerCurrent.setType(7);
        }
        if (answer.status != 1002) {
          await handler.updateSale(
              {'isUpdate': 0, 'fecha': DateTime.now().toString(), 'isError': 1},
              id);
        }
        return AwesomeDialog(
          context: context,
          dialogType:
              answer.status == 1002 ? DialogType.warning : DialogType.error,
          animType: AnimType.rightSlide,
          title:
              answer.status == 1002 ? 'Venta registrada con exito' : '¡Upss!',
          dismissOnTouchOutside: false,
          desc: answer.status == 1002 ? messajeConnection : answer.message,
          btnOkText: "Aceptar",
          btnOkOnPress: () => Navigator.pop(context, true),
        ).show();
      }
    });
  }

  setDataSuccess() {}

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
      appBar: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(),),
      body: Stack(
        children: [
          header(),
          isLoading ? const LoadingJunghanns() : itemList(),
          Visibility(visible: isRequestFolio, child: requestFolio())
        ],
      ),
      bottomNavigationBar:
          bottomBar(() {}, widget.index,context, isHome: false),
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
              widget.authList.isNotEmpty
                  ? "No hay suficiente stock de ${widget.authList.first.product.description} para la autorizacion"
                  : "Sin productos",
              style: TextStyles.blue18SemiBoldIt,
              textAlign: TextAlign.center,
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
                                        int isAdd) {
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
                                  update:
                                      (ProductModel productCurrent, int isAdd) {
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
                Visibility(
                    visible: productListOther.isNotEmpty,
                    child: Container(
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
                            label: isOtherProduct
                                ? "Regresar"
                                : "Otros Productos"))),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                    visible: provider.basketCurrent.sales
                        .where((element) => element.number > 0)
                        .isNotEmpty,
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 10),
                        width: double.infinity,
                        height: 45,
                        alignment: Alignment.center,
                        child: ButtonJunghanns(
                          decoration: Decorations.blueBorder12,
                          fun: caseSale,
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
              provider.connectionStatus == 4
                  ? const WithoutInternet()
                  : provider.isNeedAsync
                      ? const NeedAsync()
                      : Container(),
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
          child: folios.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      child: const Text("No se encontraron folios Asignados")))
              : Stack(
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
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(width: 2, color: ColorsJunghanns.blueJ),
              borderRadius: BorderRadius.circular(8),
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
          var exits = folios.where((element) =>
              element.getValid(widget.customerCurrent.payment.first.wayToPay) &&
              element.number == int.parse(folioC.text));
          if (exits.isEmpty) {
            setState(() {
              isLoading = false;
              errFolio = "* No se encontro el folio";
              isRequestFolio = true;
            });
          } else {
            if (exits.first.status == 1) {
              log("se encontro exitosamente el folio");
              provider.basketCurrent.folio = int.parse(folioC.text);
              setState(() {
                isLoading = false;
              });
              if (widget.authList.isNotEmpty) {
                if (widget.authList.first.authText == "PRESTAMO") {
                  //validamos que sea un prestamo para desplegar el picker de fecha
                  _selectDate(context);
                } else {
                  //validamos que sea credito ocasional para terminar la venta
                  if (widget.authList.first.authText == "CREDITO OCASIONAL") {
                    showConfirmSale(widget.customerCurrent.payment.first);
                  }else{
                  // validamos que sea precio especial
                  if (widget.authList.first.authText == "PRECIO ESPECIAL") {
                    showConfirmSale(widget.customerCurrent.payment.first);
                  }else{
                    Fluttertoast.showToast(
          msg: "No se ha encontrado un procedimiento para esta venta",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
                  }
                  }
                }
              } else {
                showConfirmSale(widget.customerCurrent.payment.first);
              }
            } else {
              log("evento de boton validar");
            }
          }
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
          if (methodCurrent.getIsFolio()) {
            //habilitamos el modal para folio
            setState(() {
              isRequestFolio = true;
            });
          } else {
            if (provider.basketCurrent.authCurrent.authText.toUpperCase() ==
                "GARRAFON A LA PAR") {
              List<Map<String, dynamic>> list = List.from(
                  jsonDecode(prefs.brands != "" ? prefs.brands : "[]"));
              if (list.isNotEmpty) {
                provider.basketCurrent.brandJug = list.first;
                showBrand(context, () => showConfirmSale(methodCurrent),
                    provider, list);
              } else {
                Fluttertoast.showToast(
                  msg: "No se encontraron marcas de garrafon",
                  timeInSecForIosWeb: 2,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  webShowClose: true,
                );
                provider.basketCurrent.brandJug = {
                  "id": 0,
                  "descripcion": "Sin marca"
                };
                showConfirmSale(methodCurrent);
              }
            } else {
              showConfirmSale(methodCurrent);
            }
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
