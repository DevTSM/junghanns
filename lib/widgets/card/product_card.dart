import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';

import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductCard extends StatefulWidget {
  final String image, productB, productN, price;
  const ProductCard(
      {Key? key,
      required this.image,
      required this.productB,
      required this.productN,
      required this.price})
      : super(key: key);

  @override
  ProductCardState createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  var myGroup = AutoSizeGroup();
  bool isSelect = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(15),
            decoration:
                isSelect ? Decorations.blueCard : Decorations.whiteJCard,
            child: Column(
              children: [
                Expanded(flex: 6, child: imageProduct()),
                Expanded(flex: 2, child: textProduct()),
                Expanded(flex: 2, child: priceProduct()),
              ],
            )),
        onTap: () {
          setState(() {
            isSelect = !isSelect;
          });
        });
  }

  Widget imageProduct() {
    return Container(
        width: double.infinity,
        decoration: Decorations.white2Card,
        padding: const EdgeInsets.all(2),
        child: Image.asset(
          widget.image,
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
              widget.productB,
              maxLines: 1,
              group: myGroup,
              style: TextStyles.blueJ20BoldIt,
            )),
            widget.productN.isNotEmpty
                ? Flexible(
                    child: AutoSizeText(
                      widget.productN,
                      maxLines: 1,
                      group: myGroup,
                      style: TextStyles.blueJ20It,
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
              widget.price,
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
