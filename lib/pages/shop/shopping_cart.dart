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
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/models/shopping_basket.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junghanns/widgets/card/product_card.dart';
import 'package:junghanns/widgets/card/product_card_priority.dart';

import '../../models/method_payment.dart';

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
  late List<ProductModel> productsList = [];
  late List<MethodPayment> paymentsList = [];

  late double totalPrice;
  late bool isLoading;
  //
  late BasketModel basket;
  late int cantidad;
  late List<ConfigModel> configList = [];
  late double distance;

  @override
  void initState() {
    super.initState();

    totalPrice = 0;
    isLoading = true;
    //
    cantidad = 0;
    distance=0;
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
        typeOperation: "V");

    getDataProducts();
  }

  getDataProducts() async {
    log("${prefs.idRouteD}");
    await getStockList(prefs.idRouteD).then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin productos",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        answer.body.map((e) {
          productsList.add(ProductModel.fromServiceProduct(e));
        }).toList();
        checkPriceCvsPriceS();
      }
      getDataPayment();
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
        bool isNotAuth = true;

        //
        if (widget.authList.isNotEmpty) {
          if (widget.authList.first.price == 0) {
            isNotAuth = false;
            paymentsList.add(MethodPayment(
                wayToPay: "Efectivo",
                typeWayToPay: "E",
                type: "Autorizacion",
                idProductService: widget.authList.first.idProduct,
                description: widget.authList.first.description,
                number: widget.authList.first.number));
          }
        }
        //
        if (isNotAuth) {
          answer.body
              .map((e) => paymentsList.add(MethodPayment.fromService(e)))
              .toList();

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
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  updateTotal(int id, double price, bool isAdd) {
    if (widget.authList.isEmpty) {
      for (var e in productsList) {
        if (e.idProduct == id) {
          isAdd ? updateShoppingAdd(e) : updateShoppingSubtraction(e);
        }
      }
    } else {
      for (var e in widget.authList) {
        if (e.idProduct == id) {
          isAdd
              ? updateShoppingAdd(e.getProduct())
              : updateShoppingSubtraction(e.getProduct());
        }
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
      child: productsList.isEmpty
          ? Center(
              child: Text(
              "Sin productos",
              style: TextStyles.blue18SemiBoldIt,
            ))
          : Column(
              children: [
                ProductCardPriority(
                    productCurrent: widget.authList.isEmpty
                        ? productsList.first
                        : widget.authList.first.getProduct(),
                    update: updateTotal),
                Expanded(
                  child: widget.authList.isEmpty
                      ? GridView.custom(
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
                                  isPR: true,
                                  productCurrent: productsList[index + 1]),
                              childCount: productsList.length - 1),
                        )
                      : Container(),
                ),
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
                          fun: () {
                            log("Venta check");
                            if (paymentsList.length > 1) {
                              selectWayToPay();
                            } else {
                              if (funCheckMethodPayment(paymentsList.first)) {
                                showConfirmSale(paymentsList.first);
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

  bool funCheckMethodPayment(MethodPayment methodCurrent) {
    bool isTrue = false;
    log("TIPO DE PAGO - ${methodCurrent.wayToPay}");
    switch (methodCurrent.wayToPay) {
      case "Efectivo":
        isTrue = true;
        break;
      case "Credito":
        if (methodCurrent.idProductService != -1 &&
            methodCurrent.number != -1) {
          if (basket.sales.length > 1) {
            isTrue = false;
            Fluttertoast.showToast(
              msg: "Productos no válidos",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
          } else {
            if (methodCurrent.idProductService ==
                basket.sales.first.idProduct) {
              if (basket.sales.first.number <= methodCurrent.number) {
                isTrue = true;
              } else {
                Fluttertoast.showToast(
                  msg: "Cantidad no válida",
                  timeInSecForIosWeb: 2,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  webShowClose: true,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Producto no válido",
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            }
          }
        } else {
          isTrue = false;
        }
        break;
      case "Monedero":
        if (totalPrice > widget.customerCurrent.purse) {
          isTrue = false;
          Fluttertoast.showToast(
            msg: "Monedero insuficiente",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
        } else {
          isTrue = true;
        }
        break;
    }
    log("ISTRUE - $isTrue");
    return isTrue;
  }

  Widget showItem(MethodPayment methodCurrent, String text2, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (funCheckMethodPayment(methodCurrent)) {
          showConfirmSale(methodCurrent);
        }
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

    if (widget.authList.isNotEmpty) {
      basket.idAuth = widget.authList.first.idAuth;
    }
    if (basket.waysToPay.first.type == "C") {
      basket.folio = 1;
    }

    ///
    Map<String, dynamic> data = {
      "id_cliente": basket.idCustomer,
      "id_ruta": basket.idRoute,
      "latitud": basket.lat.toString(),
      "longitud": basket.lng.toString(),
      "venta": List.from(listSales.toList()),
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
                        msg: "Lejos del domicilio $distance ${distance>1?"Metro":"Metros"}",
                        timeInSecForIosWeb: 16,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        webShowClose: true,
                      );
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

  Future<bool> funCheckDistance() async {
    await getConfigR();
    //
    /*int distanConfig = widget.authList.isEmpty
        ? configList.last.valor
        : configList.first.valor;*/
    int distanConfig = configList.last.valor;
    //
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      distance=Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              widget.customerCurrent.lat,
              widget.customerCurrent.lng);
      if (distance <=
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
