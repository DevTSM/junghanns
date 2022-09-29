import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart' as loc1;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junghanns/widgets/card/product_card.dart';
import 'package:provider/provider.dart';

import '../../models/method_payment.dart';
import '../../models/shopping_basket.dart';

class ShoppingCartRefill extends StatefulWidget {
  CustomerModel customerCurrent;

  ShoppingCartRefill({
    Key? key,
    required this.customerCurrent,
  }) : super(key: key);

  @override
  State<ShoppingCartRefill> createState() => _ShoppingCartRefillState();
}

class _ShoppingCartRefillState extends State<ShoppingCartRefill> {
  late Size size;
  late List<ProductModel> refillList = [];
  late List<MethodPayment> paymentsList = [];

  late double totalPrice;
  late bool isLoading;
  //
  late BasketModel basket;
  late int cantidad;
  late List<ConfigModel> configList;
  late double distance;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  //
  late ProviderJunghanns provider;
  //
  late double latSale, lngSale;

  @override
  void initState() {
    super.initState();

    totalPrice = 0;
    isLoading = false;
    //
    cantidad = 0;
    distance = 0;
    basket = BasketModel(
        idCustomer: widget.customerCurrent.idClient,
        idRoute: prefs.idRouteD,
        lat: widget.customerCurrent.lat,
        lng: widget.customerCurrent.lng,
        sales: [],
        idAuth: -1,
        waysToPay: [],
        idDataOrigin: widget.customerCurrent.id,
        folio: -1,
        typeOperation: "R",
        totalPrice: 0);
    configList = [];
    latSale = lngSale = 0;

    getDataRefill();
  }

  getDataRefill() async {
    Timer(const Duration(milliseconds: 800), () async {
      if (provider.connectionStatus < 4) {
        setState(() {
          isLoading = true;
        });
        await getRefillList(prefs.idRouteD).then((answer) {
          if (answer.error) {
            Fluttertoast.showToast(
              msg: "Sin recargas",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
          } else {
            refillList.clear();

            answer.body
                .map((e) => refillList.add(ProductModel.fromServiceRefill(e)))
                .toList();
          }
          getDataPayment();
        });
      }
    });
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
        paymentsList.clear();
        answer.body.map((e) {
          if (e["formaPago"] == "Efectivo") {
            paymentsList.add(MethodPayment.fromService(e));
          }
        }).toList();
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  updateTotal(int id, double price, bool isAdd) {
    for (var e in refillList) {
      if (e.idProduct == id) {
        isAdd ? updateShoppingAdd(e) : updateShoppingSubtraction(e);
      }
    }

    setState(() {
      if (isAdd) {
        cantidad = cantidad + 1;
        totalPrice = totalPrice + price;
      } else {
        cantidad = cantidad - 1;
        totalPrice = totalPrice - price;
      }
    });
  }

  updateShoppingAdd(ProductModel prod) {
    if (basket.sales.isEmpty) {
      basket.sales.add(prod);
      log("FIRST ADD ID: ${basket.sales.first.idProduct}, CANTIDAD: ${basket.sales.first.number}");
    } else {
      int index = basket.sales
          .indexWhere((element) => element.idProduct == prod.idProduct);
      if (index != -1) {
        basket.sales[index].number = basket.sales[index].number + 1;
        log("ADD ONE TO ID: ${basket.sales[index].idProduct} -- CANTIDA: ${basket.sales[index].number}");
      } else {
        basket.sales.add(prod);
        log("NEW ADD ID: ${basket.sales.last.idProduct}");
      }
    }
  }

  updateShoppingSubtraction(ProductModel prod) {
    if (basket.sales.isNotEmpty) {
      int index = basket.sales
          .indexWhere((element) => element.idProduct == prod.idProduct);
      if (index != -1) {
        if (basket.sales[index].number > 1) {
          basket.sales[index].number = basket.sales[index].number - 1;
          log("SUBTRACTION TO ID: ${basket.sales[index].idProduct} -- CANTIDA: ${basket.sales[index].number}");
        } else {
          log("REMOVE ID: ${basket.sales[index].idProduct}");
          basket.sales.removeAt(index);
        }
      } else {
        log("RESTA -- SIN PRODUCTO");
      }
    } else {
      log("RESTA -- LISTA SIN PRODUCTOS");
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
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menuWhite.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [header(), isLoading ? const LoadingJunghanns() : itemList()],
      ),
      bottomNavigationBar: bottomBar(() {}, 2, isHome: false, context: context),
    );
  }

  Widget header() {
    return Container(
        color: ColorsJunghanns.green,
        padding: EdgeInsets.only(
            right: 15, left: 23, top: 10, bottom: size.height * .05),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                              //shoppingBasket.length.toString(),
                              cantidad.toString(),
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
                      Text(
                        formatMoney.format(totalPrice),
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

  Widget itemList() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .22),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      child: refillList.isEmpty
          ? Center(
              child: Text(
              "Sin recargas",
              style: TextStyles.blue18SemiBoldIt,
            ))
          : Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: SizedBox(
                  width: size.width,
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
                        (context, index) => ProductCard(
                              update: updateTotal,
                              isPR: false,
                              productCurrent: refillList[index],
                            ),
                        childCount: refillList.length),
                  ),
                )),
                Visibility(
                    visible: cantidad > 0,
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 30, top: 30),
                        width: double.infinity,
                        height: 40,
                        alignment: Alignment.center,
                        child: ButtonJunghanns(
                          decoration: Decorations.blueBorder12,
                          fun: () => showConfirmSale(paymentsList.first),
                          label: "Terminar venta",
                          style: TextStyles.white17_5,
                        )))
              ],
            ),
    );
  }

  showConfirmSale(MethodPayment methodCurrent) {
    if (provider.connectionStatus < 4) {
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
                    textWayToPay(methodCurrent.wayToPay),
                    textAmount(),
                    buttomsSale(methodCurrent)
                  ],
                ),
              ),
            );
          });
    } else {
      Fluttertoast.showToast(
        msg: "Sin conexión a internet",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  Widget textWayToPay(String wayToPay) {
    return Container(
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyles.blueJ22Bold,
            child: Text("¿Pago en $wayToPay ?")));
  }

  Widget textAmount() {
    return Column(
      children: [
        DefaultTextStyle(
            style: TextStyles.blueJ215R,
            child: const Text(
              "Deseas registrar la venta de:",
            )),
        DefaultTextStyle(
            style: TextStyles.greenJ24Bold,
            child: Text(formatMoney.format(totalPrice))),
      ],
    );
  }

  funSale(MethodPayment methodPayment) async {
    log("FUNCIÓN DE VENTA");
    log("FORMA DE PAGO - ${methodPayment.wayToPay}");

    basket.waysToPay
        .add(WayToPay(type: methodPayment.typeWayToPay, cost: totalPrice));
    log("FORMA DE PAGO - ${basket.waysToPay.first.type}");
    log("TOTAL - ${basket.waysToPay.first.cost}");

    ///
    List<Map> listSales = [];
    for (var element in basket.sales) {
      listSales.add({
        "cantidad": element.number,
        "id_producto": element.idProduct,
        "precio_unitario": element.price
      });
    }

    List<Map> listWaysToPay = [];
    for (var ele in basket.waysToPay) {
      listWaysToPay.add({
        "tipo": ele.type,
        "importe": ele.cost,
      });
    }

    ///
    Map<String, dynamic> data = {
      "id_cliente": basket.idCustomer,
      "id_ruta": basket.idRoute,
      "latitud": latSale.toString(),
      "longitud": lngSale.toString(),
      "venta": listSales,
      "id_autorizacion": basket.idAuth != -1 ? basket.idAuth : null,
      "formas_de_pago": listWaysToPay,
      "id_data_origen": basket.idDataOrigin,
      "folio": basket.folio != -1 ? basket.folio : null,
      "tipo_operacion": basket.typeOperation,
      "version": "1.13"
    };

    log("LA DATA ES: $data");

    await postSale(data).then((answer) {
      setState(() {
        isLoading = false;
      });
      if (answer.error) {
        //Navigator.pop(context);
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        //Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Venta realizada con exito",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );

        Navigator.pop(context);
      }
    });
  }

  Widget buttomsSale(MethodPayment methodPayment) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buttomSale(
              "Si",
              () => () async {
                    Navigator.pop(context);
                    //onLoading();
                    setState(() {
                      isLoading = true;
                    });
                    //bool isD = await funCheckDistance();
                    bool isD = await funCheckDistance2();
                    if (isD) {
                      if (latSale != 0 && lngSale != 0) {
                        funSale(methodPayment);
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
                      //Navigator.pop(context);
                      setState(() {
                        isLoading = false;
                      });
                    }
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

  getConfigR() async {
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
        log("Config yes");
        answer.body
            .map((e) => configList.add(ConfigModel.fromService(e)))
            .toList();
      }
    });
  }
  //
  ///--------------------------------------------------------------------------

  Future<bool> funCheckDistance2() async {
    await getConfigR();
    log("***LOCATION FUN***");
    loc1.Location loc = loc1.Location();
    bool serviceEnabled;
    loc1.PermissionStatus permissionGranted;
    loc1.LocationData locationData;

    serviceEnabled = await loc.serviceEnabled();
    log("Service is : $serviceEnabled");
    if (serviceEnabled == false) {
      serviceEnabled = await loc.requestService();
    }
    if (serviceEnabled) {
      permissionGranted = await loc.hasPermission();
      if (permissionGranted != loc1.PermissionStatus.granted) {
        log("Request Location Permission");
        permissionGranted = await loc.requestPermission();
      }
      if (permissionGranted == loc1.PermissionStatus.granted) {
        log("Permission true");
        loc.changeSettings(accuracy: loc1.LocationAccuracy.high);
        try {
          locationData =
              await loc.getLocation().timeout(const Duration(seconds: 15));
          latSale = locationData.latitude ?? 0;
          lngSale = locationData.longitude ?? 0;
          log("Coordenadas : $latSale, $lngSale");
          distance = calculateDistance(
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng,
                  locationData.latitude,
                  locationData.longitude) *
              1000;

          log("LatL: ${locationData.latitude} and LngL: ${locationData.longitude}");
          log("LatC: ${widget.customerCurrent.lat} and LngC: ${widget.customerCurrent.lng}");
          log("Distance loc is $distance");

          if (distance <= configList.last.valor) {
            return true;
          } else {
            Fluttertoast.showToast(
              msg:
                  "Lejos del domicilio $distance ${distance > 1 ? "Metro" : "Metros"}",
              timeInSecForIosWeb: 16,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            return false;
          }
        } catch (e) {
          log("***ERROR -- $e");
          Fluttertoast.showToast(
              msg: "Tiempo de espera superado, vuelve a intentarlo",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor: CupertinoColors.systemRed);
          return false;
        }
      } else {
        log("Permission false");
        Fluttertoast.showToast(
            msg: "Debes permitir el uso de la ubicación, vuelve a intentarlo",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
            backgroundColor: CupertinoColors.systemRed);
        return false;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Debes activar el servicio de ubicación, vuelve a intentarlo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: CupertinoColors.systemRed);
      return false;
    }
  }

  ///
  ///--------------------------------------------------------------------------

  Future<bool> funCheckDistance() async {
    await getConfigR();
    //
    int distanConfig = configList.last.valor;
    //
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      latSale = _currentLocation.latitude;
      lngSale = _currentLocation.longitude;
      log("Coordenadas : $latSale, $lngSale");
      distance = Geolocator.distanceBetween(
          _currentLocation.latitude,
          _currentLocation.longitude,
          widget.customerCurrent.lat,
          widget.customerCurrent.lng);
      if (distance <= distanConfig) {
        return true;
      } else {
        return false;
      }
    } else {
      log("permission: $permission");
      return false;
    }
  }
}
