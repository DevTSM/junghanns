import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:junghanns/widgets/card/product_card.dart';

import '../../widgets/card/refill_card.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({Key? key}) : super(key: key);

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late Size size;
  late List<RefillModel> refillList = [];
  late List<ProductModel> productsList = [];
  late double totalPrice;
  late int totalItem;
  late bool isProduct;

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    totalItem = 0;
    isProduct = true;
    getDataProducts();
  }

  getDataProducts() async {
    await getProductList().then((answer) {
      getDataRefill();
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
            .addAll([ProductModel.fromState(), ProductModel.fromState()]);
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
              .map((e) => refillList.add(RefillModel.fromService(e)))
              .toList();
        });
      }
    });
  }

  setitemRefill() {
    setState(() {
      isProduct = false;
    });
  }

  setitemProduct() {
    setState(() {
      isProduct = true;
    });
  }

  updateTotal() {
    var data = productsList.where((element) => element.isSelect);
    setState(() {
      totalItem = data.length;
      totalPrice = 0;
      productsList.map((e) {
        setState(() {
          e.isSelect ? totalPrice += e.price : null;
        });
      }).toList();
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
            right: 15, left: 23, top: 10, bottom: size.height * .08),
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
                              totalItem.toString(),
                              style: TextStyles.white24SemiBoldIt,
                            ),
                          ),
                          Image.asset(
                            "assets/icons/shoppingIcon.png",
                            width: 60,
                          )
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
                ],
              ),
            ]));
  }

  Widget itemList() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .18),
      padding: const EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: ButtonJunghanns(
                      isIcon: true,
                      icon: Image.asset(
                        isProduct
                            ? "assets/icons/shopP2.png"
                            : "assets/icons/shopP1.png",
                        width: size.width * 0.14,
                      ),
                      fun: setitemProduct,
                      decoration: isProduct
                          ? Decorations.blueBorder12
                          : Decorations.whiteBorder12,
                      style: isProduct
                          ? TextStyles.white14_5
                          : TextStyles.blue16_4,
                      label: "Productos")),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: ButtonJunghanns(
                      isIcon: true,
                      icon: Image.asset(
                          !isProduct
                              ? "assets/icons/shopR2.png"
                              : "assets/icons/shopR1.png",
                          width: size.width * 0.14),
                      fun: setitemRefill,
                      decoration: isProduct
                          ? Decorations.whiteBorder12
                          : Decorations.blueBorder12,
                      style: isProduct
                          ? TextStyles.blue16_4
                          : TextStyles.white14_5,
                      label: "Recargas"))
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: Container(
            width: size.width,
            child: GridView.custom(
              gridDelegate: SliverWovenGridDelegate.count(
                crossAxisCount: 2,
                mainAxisSpacing: 30,
                crossAxisSpacing: 30,
                pattern: [
                  WovenGridTile(.85),
                  WovenGridTile(.85),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => isProduct
                      ? ProductCard(
                          update: updateTotal,
                          productCurrent: productsList[index],
                        )
                      : RefillCard(
                          refillCurrent: refillList[index],
                        ),
                  childCount:
                      isProduct ? productsList.length : refillList.length),
            ),
          )),
          Visibility(
              visible: totalItem > 0,
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
              actions: [
                showItem("Contado", "Pago total de la compra",
                    FontAwesomeIcons.coins),
                showItem("Credito", "Pago parte de la compra",
                    FontAwesomeIcons.solidCreditCard)
              ]);
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

  Widget showItem(String text1, String text2, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
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
                      text1,
                    )),
                DefaultTextStyle(
                    style: TextStyles.blueJ215R,
                    child: Text(
                      text2,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}