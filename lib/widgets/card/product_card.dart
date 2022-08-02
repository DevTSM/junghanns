import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/styles/color.dart';

import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductCard extends StatefulWidget {
  ProductModel productCurrent;
  bool isPR;
  Function update;
  ProductCard(
      {Key? key,
      required this.productCurrent,
      required this.isPR,
      required this.update})
      : super(key: key);

  @override
  ProductCardState createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  var myGroup = AutoSizeGroup();
  int amount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(15),
            decoration: widget.productCurrent.isSelect
                ? Decorations.blueCard
                : Decorations.whiteJCard,
            child: Column(
              children: [
                Expanded(flex: 8, child: imageProduct()),
                Expanded(flex: 2, child: textProduct()),
                Expanded(flex: 3, child: priceProduct()),
              ],
            )),
        onTap: () {
          /*setState(() {
            widget.productCurrent.setSelect(amount > 0);
          });
          widget.update(widget.productCurrent.type, amount);*/
        });
  }

  Widget imageProduct() {
    return Container(
        width: double.infinity,
        decoration: Decorations.white2Card,
        padding: const EdgeInsets.all(1),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                widget.productCurrent.img,
                fit: BoxFit.contain,
              ),
            ),
            widget.isPR && amount > 0
                ? Align(alignment: Alignment.topRight, child: stockProduct())
                : Container()
          ],
        ));
  }

  Widget textProduct() {
    return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: AutoSizeText(
              widget.productCurrent.name[0],
              maxLines: 1,
              group: myGroup,
              style: TextStyles.blueJ20BoldIt,
            )),
            widget.isPR
                ? Flexible(
                    child: AutoSizeText(
                      widget.productCurrent.name[1],
                      maxLines: 1,
                      group: myGroup,
                      style: TextStyles.blueJ20It,
                    ),
                  )
                : Container()
          ],
        ));
  }

  Widget stockProduct() {
    return Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(top: 5, right: 5),
        alignment: Alignment.center,
        decoration: Decorations.greenJCardB30,
        child: AutoSizeText(
          amount.toString(),
          style: TextStyles.white15Itw,
        ));
  }

  Widget priceProduct() {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      decoration: Decorations.white2Card,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              checkDouble(widget.productCurrent.price.toString()),
              style: TextStyles.blueJ20BoldIt,
            ),
          ),
          buttonAdd(),
          buttonSubtract(),
          /*Container(
              margin: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: Image.asset("assets/icons/arrowGreen.png"))*/
        ],
      ),
    );
  }

  buttonAdd() {
    return GestureDetector(
      child: Container(
          margin: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: const Icon(
            FontAwesomeIcons.plus,
            size: 22,
            color: ColorsJunghanns.greenJ,
          )),
      onTap: () => funAdd(),
    );
  }

  funAdd() {
    setState(() {
      amount++;
      widget.productCurrent.setSelect(amount > 0);
    });
    log("Sumar $amount");
    log("ID ${widget.productCurrent.id}");
    widget.update(widget.productCurrent.type, widget.productCurrent.id,
        widget.productCurrent.price, true);
  }

  buttonSubtract() {
    return GestureDetector(
        child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: const Icon(
              FontAwesomeIcons.minus,
              size: 22,
              color: ColorsJunghanns.red,
            )),
        onTap: () => funSubtract());
  }

  funSubtract() {
    if (amount > 0) {
      setState(() {
        amount--;
        widget.productCurrent.setSelect(amount > 0);
      });
      log("Restar $amount");
      widget.update(widget.productCurrent.type, widget.productCurrent.id,
          widget.productCurrent.price, false);
    }
  }
}
