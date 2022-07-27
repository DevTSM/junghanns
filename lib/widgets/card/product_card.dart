import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/sale.dart';

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
          setState(() {
            widget.productCurrent.setSelect(!widget.productCurrent.isSelect);
          });
          widget.update(widget.productCurrent.type);
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
            widget.isPR
                ? Align(alignment: Alignment.topRight, child: stockProduct(52))
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

  Widget stockProduct(int stock) {
    return Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(top: 5, right: 5),
        alignment: Alignment.center,
        decoration:
            stock > 0 ? Decorations.greenJCardB30 : Decorations.redCardB30,
        child: AutoSizeText(
          stock.toString(),
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
          Container(
              margin: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: Image.asset("assets/icons/arrowGreen.png"))
        ],
      ),
    );
  }
}
