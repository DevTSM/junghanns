import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/styles/color.dart';

import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductCardPriority extends StatefulWidget {
  ProductModel productCurrent;
  Function update;

  ProductCardPriority(
      {Key? key, required this.productCurrent, required this.update})
      : super(key: key);

  @override
  ProductCardPriorityState createState() => ProductCardPriorityState();
}

class ProductCardPriorityState extends State<ProductCardPriority> {
  int _amount = 0;
  int stock2 = 0;
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");

  @override
  void initState() {
    super.initState();

    stock2 = widget.productCurrent.stock;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            width: double.infinity,
            height: size.height * 0.17,
            decoration: widget.productCurrent.isSelect
                ? Decorations.blueCard
                : Decorations.whiteJCard,
            child: Row(
              children: [
                Expanded(flex: 5, child: imageProduct()),
                Expanded(flex: 7, child: info()),
              ],
            )),
        onTap: () {
          showSelect();
        });
  }

  Widget info() {
    return Container(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [textProduct(), stockProduct(), priceProduct()],
        ));
  }

  Widget imageProduct() {
    return Container(
        width: double.infinity,
        decoration: Decorations.white2Card,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.productCurrent.img))),
            ),
            _amount > 0
                ? Align(alignment: Alignment.topRight, child: numberProduct())
                : Container()
          ],
        ));
  }

  Widget textProduct() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
            child: AutoSizeText(
          widget.productCurrent.description,
          maxLines: 1,
          style: TextStyles.blueJ20BoldIt,
        )),
      ],
    );
  }

  Widget numberProduct() {
    return Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(top: 2, right: 2),
        alignment: Alignment.center,
        decoration: Decorations.greenJCardB30,
        child: AutoSizeText(
          _amount.toString(),
          style: TextStyles.white30SemiBold,
        ));
  }

  Widget stockProduct() {
    return Container(
        margin: const EdgeInsets.only(bottom: 2, left: 28, right: 28),
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        alignment: Alignment.center,
        decoration: Decorations.greenJCardB30,
        child: AutoSizeText(
          "Stock: $stock2",
          style: TextStyles.white15Itw,
        ));
  }

  Widget priceProduct() {
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: Decorations.white2Card,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              formatMoney.format(widget.productCurrent.price),
              textAlign: TextAlign.center,
              style: TextStyles.blueJ20BoldIt,
            ),
          ),
          //buttonAdd(),
          //buttonSubtract(),
        ],
      ),
    );
  }

  funAdd() {
    if (stock2 > 0) {
      setState(() {
        _amount++;
        stock2--;
        widget.productCurrent.setSelect(_amount > 0);
      });
      log("Sumar $_amount");
      log("Stock2 - $stock2");
      log("Stock1 - ${widget.productCurrent.stock}");
      log("ID ${widget.productCurrent.idProduct}");
      widget.update(
          widget.productCurrent.idProduct, widget.productCurrent.price, true);
    }
  }

  funSubtract() {
    if (_amount > 0) {
      setState(() {
        _amount--;
        stock2++;
        widget.productCurrent.setSelect(_amount > 0);
      });
      log("Restar $_amount");
      log("Stock2 - $stock2");
      log("Stock1 - ${widget.productCurrent.stock}");
      widget.update(
          widget.productCurrent.idProduct, widget.productCurrent.price, false);
    }
  }

  Widget textP() {
    return Container(
        margin: const EdgeInsets.only(top: 8),
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyles.blueJ18Bold,
            child: Text(widget.productCurrent.description)));
  }

  Widget textAmount() {
    return DefaultTextStyle(
      style: TextStyles.greenJ30Bold,
      child: Text(
        "$_amount",
      ),
    );
  }

  showSelect() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    padding: const EdgeInsets.all(12),
                    width: size.width * .75,
                    decoration: Decorations.whiteS1Card,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //PRODUCTO
                        textP(),

                        //BOTONES
                        Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //BOTON DE MENOS
                                GestureDetector(
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.minus,
                                          size: 35,
                                          color: ColorsJunghanns.red,
                                        )),
                                    onTap: () {
                                      setState(() {
                                        funSubtract();
                                      });
                                    }),

                                //CANTIDAD
                                textAmount(),

                                //BOTON DE MAS
                                GestureDetector(
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.plus,
                                          size: 35,
                                          color: ColorsJunghanns.greenJ,
                                        )),
                                    onTap: () {
                                      setState(() {
                                        funAdd();
                                      });
                                    })
                              ],
                            )),

                        GestureDetector(
                          child: Container(
                            decoration: Decorations.blueBorder12,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            alignment: Alignment.center,
                            child: const Text(
                              "CONFIRMAR",
                              style: TextStyles.white17_5,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                )));
  }
}
