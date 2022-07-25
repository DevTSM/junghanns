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
                widget.isPR ? stockProduct(0) : Container(),
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
        child: Image.asset(
          widget.productCurrent.img,
          fit: BoxFit.contain,
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
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 6),
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        decoration: stock > 0 ? Decorations.greenJCard : Decorations.redCard,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: AutoSizeText(
              stock > 0 ? "Stock:  " : "Sin Stock",
              maxLines: 1,
              style: TextStyles.white15Itw,
            )),
            stock > 0
                ? Flexible(
                    child: AutoSizeText(
                      stock.toString(),
                      maxLines: 1,
                      style: TextStyles.white15BoldIt,
                    ),
                  )
                : Container()
          ],
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
