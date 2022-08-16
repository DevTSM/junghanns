import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junghanns/widgets/card/product_card.dart';

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

  @override
  void initState() {
    super.initState();

    totalPrice = 0;
    isLoading = true;
    //
    cantidad = 0;
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
        typeOperation: "R");
    configList = [];

    getDataRefill();
  }

  getDataRefill() async {
    log("${prefs.idRouteD}");
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

  getDataPayment() async {
    log("Cliente: ${widget.customerCurrent.idClient}");
    log("Ruta: ${prefs.idRouteD}");
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
      basket.sales.add(ProductB(
          number: 1, idProduct: prod.idProduct, unitPrice: prod.price));
      log("FIRST ADD ID: ${basket.sales.first.idProduct}, CANTIDAD: ${basket.sales.first.number}");
    } else {
      int index = basket.sales
          .indexWhere((element) => element.idProduct == prod.idProduct);
      if (index != -1) {
        basket.sales[index].number = basket.sales[index].number + 1;
        log("ADD ONE TO ID: ${basket.sales[index].idProduct} -- CANTIDA: ${basket.sales[index].number}");
      } else {
        basket.sales.add(ProductB(
            number: 1, idProduct: prod.idProduct, unitPrice: prod.price));
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
        children: [header(), isLoading ? loading() : itemList()],
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
                        checkDouble(totalPrice.toString()),
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
                    child: Container(
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
                          fun: () => selectWayToPay(),
                          label: "Terminar venta",
                          style: TextStyles.white17_5,
                        )))
              ],
            ),
    );
  }

  void selectWayToPay() async {
    await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actionScrollController: ScrollController(
                  initialScrollOffset: 1.0, keepScrollOffset: true),
              title: showTitle(),
              actions: paymentsList.map((item) {
                return showItem(
                    item, "Pago total de la compra", FontAwesomeIcons.coins);
              }).toList());
        });
  }

  Widget showTitle() {
    return Row(
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
    );
  }

  Widget showItem(MethodPayment methodCurrent, String text2, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);

        showConfirmSale(methodCurrent);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 35, top: 8, bottom: 8),
        child: Row(
          children: [
            Container(
                decoration: Decorations.blueJ2Card,
                padding: const EdgeInsets.only(
                    right: 10, left: 7, top: 5, bottom: 7),
                margin: const EdgeInsets.only(right: 15),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                    style: TextStyles.blueJ220Bold,
                    child: Text(
                      methodCurrent.wayToPay,
                    )),
                /*DefaultTextStyle(
                    style: TextStyles.blueJ215R,
                    child: Text(
                      text2,
                    ))*/
              ],
            ),
          ],
        ),
      ),
    );
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
                  textWayToPay(methodCurrent.wayToPay),
                  textAmount(),
                  buttomsSale(methodCurrent)
                ],
              ),
            ),
          );
        });
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
            child: Text(
              checkDouble(totalPrice.toString()),
            )),
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
        "precio_unitario": element.unitPrice
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
      "latitud": basket.lat.toString(),
      "longitud": basket.lng.toString(),
      "venta": listSales,
      "id_autorizacion": basket.idAuth != -1 ? basket.idAuth : null,
      "formas_de_pago": listWaysToPay,
      "id_data_origen": basket.idDataOrigin,
      "folio": basket.folio != -1 ? basket.folio : null,
      "tipo_operacion": basket.typeOperation
    };

    log("LA DATA ES: $data");

    await postSale(data).then((answer) {
      if (answer.error) {
        Navigator.pop(context);
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
          msg: "Venta realizada con exito",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        Navigator.pop(context);
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
                    onLoading();
                    bool isD = await funCheckDistance();
                    if (isD) {
                      funSale(methodPayment);
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
                  },
              /*() async {
                    Map<String, dynamic> data = {
                      "idCliente": widget.customerCurrent.idClient,
                      "idCatRuta": 21,
                      "latitud": widget.customerCurrent.lat,
                      "longitud": widget.customerCurrent.lng,
                      "cantidad": 1,
                      "precioUnitario": totalPrice,
                      "idProductoServicio": 22,
                      "idAutorizacion": 1,
                      "tipoFormaPago": methodPayment.typeWayToPay,
                      "idClienteOrdenVisitaRuta": widget.customerCurrent.id,
                      "folio": "552555"
                    };
                    onLoading();
                    await setSale(data).then((answer) {
                      if (answer.error) {
                        Navigator.pop(context);
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
                          msg: "Venta realizada con exito",
                          timeInSecForIosWeb: 2,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          webShowClose: true,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    });
                    Navigator.pop(context);
                  },*/
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

  Widget loading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        height: MediaQuery.of(context).size.width * .30,
        width: MediaQuery.of(context).size.width * .30,
        child: const SpinKitDualRing(
          color: Colors.white70,
          lineWidth: 4,
        ),
      ),
    );
  }

  void onLoading() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
            height: MediaQuery.of(context).size.width * .30,
            width: MediaQuery.of(context).size.width * .30,
            child: const SpinKitDualRing(
              color: Colors.white70,
              lineWidth: 4,
            ),
          ),
        );
      },
    );
  }

  getConfigR() async {
    await getConfig().then((answer) {
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

  Future<bool> funCheckDistance() async {
    await getConfigR();
    //
    int distanConfig = int.parse(configList.last.valor);
    //
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      if (Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              widget.customerCurrent.lat,
              widget.customerCurrent.lng) <
          distanConfig) {
        return true;
      } else {
        return false;
      }
    } else {
      print({"permission": permission.toString()});
      return false;
    }
  }
}
