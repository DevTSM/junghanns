import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junghanns/widgets/card/product_card.dart';

import '../../models/method_payment.dart';

class ShoppingCart extends StatefulWidget {
  CustomerModel customerCurrent;
  bool isPR;
  ShoppingCart({Key? key, required this.customerCurrent, required this.isPR})
      : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late Size size;
  late List<ProductModel> refillList = [];
  late List<ProductModel> productsList = [];
  late List<MethodPayment> paymentsList = [];
  late List shoppingBasket;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    shoppingBasket = [];
    totalPrice = 0;

    widget.isPR ? getDataProducts() : getDataRefill();
    getDataPayment();
  }

  getDataProducts() async {
    /*await getProductList().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        productsList
            .addAll([ProductModel.fromState(1), ProductModel.fromState(1)]);
      }
    });*/
    await getStockList().then((answer) {
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
          productsList
              .addAll([ProductModel.fromState(1), ProductModel.fromState(1)]);
        });
      }
    });
  }

  getDataRefill() async {
    await getRefillList().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        refillList.clear();
        setState(() {
          answer.body
              .map((e) => refillList.add(ProductModel.fromServiceRefill(e)))
              .toList();
        });
      }
    });
  }

  getDataPayment() async {
    await getPaymentMethods(1).then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        paymentsList.clear();
        setState(() {
          //log("Metodos de pago ---  " + answer.body.toString());
          answer.body
              .map((e) => paymentsList.add(MethodPayment.fromService(e)))
              .toList();
        });
      }
    });
  }

  updateTotal(int type) {
    setState(() {
      totalPrice = 0;
      shoppingBasket.clear();
      for (var e in productsList) {
        if (e.isSelect && type == 1) {
          setState(() {
            shoppingBasket.add(e);
            totalPrice += e.price;
          });
        } else {
          if (e.isSelect) {
            setState(() {
              e.setSelect(false);
            });
          }
        }
      }
      for (var e in refillList) {
        if (e.isSelect && type == 2) {
          setState(() {
            shoppingBasket.add(e);
            totalPrice += e.price;
          });
        } else {
          if (e.isSelect) {
            setState(() {
              e.setSelect(false);
            });
          }
        }
      }
    });
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
        children: [header(), itemList()],
      ),
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
                              shoppingBasket.length.toString(),
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
      margin: EdgeInsets.only(top: size.height * .2),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      child: Column(
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
                //mainAxisSpacing: 10,
                crossAxisSpacing: 14,
                pattern: [
                  WovenGridTile(.85),
                  WovenGridTile(.85),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(
                        update: updateTotal,
                        isPR: widget.isPR,
                        productCurrent: widget.isPR
                            ? productsList[index]
                            : refillList[index],
                      ),
                  childCount:
                      widget.isPR ? productsList.length : refillList.length),
            ),
          )),
          Visibility(
              visible: shoppingBasket.isNotEmpty,
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
        showConfirmSale(methodCurrent, totalPrice);
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

  showConfirmSale(MethodPayment methodCurrent, double amount) {
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
                  textAmount(amount),
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
            child: Text("¿Pago de $wayToPay ?")));
  }

  Widget textAmount(double amount) {
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
              checkDouble(amount.toString()),
            )),
      ],
    );
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
                    await setSale(data).then((answer) {
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
}
