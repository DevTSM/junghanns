import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/produc_receiption.dart';
import '../../styles/color.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';

class ProductInventaryCardPriority extends StatefulWidget {
  ProductReceiptionModel productCurrent;

  ProductInventaryCardPriority({Key? key, required this.productCurrent}) : super(key: key);

  @override
  ProductInventaryCardPriorityState createState() => ProductInventaryCardPriorityState();
}

class ProductInventaryCardPriorityState extends State<ProductInventaryCardPriority> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: Decorations.blueCard.copyWith(
        color: Decorations.blueCard.color?.withOpacity(0.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                imageProduct(),
                Positioned(
                  top: -4,
                  left: -5,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: ColorsJunghanns.green,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.productCurrent.count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),
          Flexible(
            flex: 5,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  AutoSizeText(
                    widget.productCurrent.product,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.blueJ20BoldIt,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageProduct() {
    return Container(
      width: size.width * 0.3,
      height: size.height * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.productCurrent.img,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
