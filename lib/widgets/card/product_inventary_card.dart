// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/produc_receiption.dart';
import 'package:junghanns/models/product.dart';


import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductInventaryCard extends StatefulWidget {
  ProductModel productCurrent;
  /*Function update;*/
  ProductInventaryCard(
      {Key? key, required this.productCurrent/*, required this.update*/})
      : super(key: key);

  @override
  ProductInventaryCardState createState() => ProductInventaryCardState();
}

class ProductInventaryCardState extends State<ProductInventaryCard> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController count;

  @override
  void initState() {
    super.initState();
    count=TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          width: size.width *0.50,
          height: size.height * 0.21,
          decoration: int.parse(widget.productCurrent.count) > 0
              ? Decorations.blueCard
              : Decorations.blueCard,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Imagen del producto con espacio flexible
                    Flexible(
                      flex: 5,
                      child: imageProduct(),
                    ),
                    const SizedBox(height: 15),
                    Flexible(
                      flex: 2,
                      child: AutoSizeText(
                        widget.productCurrent.description,
                        maxLines: 1,
                        style: TextStyles.blueJ20BoldIt,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      margin: const EdgeInsets.only(bottom: 2, left: 28, right: 28),
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      alignment: Alignment.center,
                      decoration: Decorations.greenJCardB30,
                      child: AutoSizeText(
                        "Stock: ${widget.productCurrent.stock}",
                        style: TextStyles.white15Itw,
                      ),
                    ),
                  ],
                ),
              )

              /*Expanded(flex: 5,
                    child: Column(
                        children: [
                          imageProduct(),
                          const SizedBox(height: 10),
                          AutoSizeText(
                            widget.productCurrent.description,
                            maxLines: 1,
                            style: TextStyles.blueJ20BoldIt,
                          ),
                          const SizedBox(height: 5),
                          Container(
                              margin: const EdgeInsets.only(bottom: 2, left: 28, right: 28),
                              padding: const EdgeInsets.only(top: 2, bottom: 2),
                              alignment: Alignment.center,
                              decoration: Decorations.greenJCardB30,
                              child: AutoSizeText(
                                "Stock: ${widget.productCurrent.stock}",
                                style: TextStyles.white15Itw,
                              )),
                        ])),*/
              /*Expanded(flex: 7, child: info()),*/
            ],
          )),
      /*onTap: () {
          showSelect();
        }*/);
  }

  Widget info() {
    return Container(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
                child: AutoSizeText(
                  widget.productCurrent.description,
                  maxLines: 1,
                  style: TextStyles.blueJ20BoldIt,
                )),

          ],
        ));
  }

  Widget imageProduct() {
    return Container(
        width: size.height * 0.2,
        height: size.height * 0.12,
        decoration: Decorations.white2Card.copyWith(
            borderRadius: BorderRadius.circular(12)
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: NetworkImage(widget.productCurrent.img))),
            ),
          ],
        ));
  }

}
