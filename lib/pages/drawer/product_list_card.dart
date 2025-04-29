// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/produc_receiption.dart';


import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductInCardPriority extends StatefulWidget {
  ProductReceiptionModel productCurrent;

  ProductInCardPriority(
      {Key? key, required this.productCurrent/*, required this.update*/})
      : super(key: key);

  @override
  ProductInCardPriorityState createState() => ProductInCardPriorityState();
}

class ProductInCardPriorityState extends State<ProductInCardPriority> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late TextEditingController count;

  @override
  void initState() {
    super.initState();
    count=TextEditingController();
  }

  @override
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        width: double.infinity,
        decoration: widget.productCurrent.count > 0
            ? Decorations.blueCard
            : Decorations.blueCard,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen a la izquierda
            imageProduct(),

            const SizedBox(width: 12),

            // Textos a la derecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    widget.productCurrent.product,
                    maxLines: 1,
                    style: TextStyles.blueJ20BoldIt,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: Decorations.greenJCardB30,
                    child: AutoSizeText(
                      "Stock: ${widget.productCurrent.count}",
                      style: TextStyles.white15Itw,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget info() {
    return Container(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
                child: AutoSizeText(
                  widget.productCurrent.product,
                  maxLines: 1,
                  style: TextStyles.blueJ20BoldIt,
                )),

          ],
        ));
  }

  Widget imageProduct() {
    return Container(
        width: size.height * 0.16,
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
