import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/refill.dart';

import '../../styles/decoration.dart';
import '../../styles/text.dart';

class RefillCard extends StatefulWidget {
  RefillModel refillCurrent;
  RefillCard({Key? key, required this.refillCurrent}) : super(key: key);

  @override
  RefillCardState createState() => RefillCardState();
}

class RefillCardState extends State<RefillCard> {
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(15),
            decoration: widget.refillCurrent.isSelect
                ? Decorations.blueCard
                : Decorations.whiteJCard,
            child: Column(
              children: [
                Expanded(flex: 4, child: imageRefill()),
                Expanded(flex: 2, child: textRefill()),
                Expanded(flex: 2, child: priceRefill()),
              ],
            )),
        onTap: () {
          setState(() {
            widget.refillCurrent.setSelect(!widget.refillCurrent.isSelect);
          });
        });
  }

  Widget imageRefill() {
    return Image.asset(
      widget.refillCurrent.img,
    );
  }

  Widget textRefill() {
    return Container(
      alignment: Alignment.center,
      child: Flexible(
          child: AutoSizeText(
        widget.refillCurrent.name,
        maxLines: 1,
        style: TextStyles.blueJ20BoldIt,
      )),
    );
  }

  Widget priceRefill() {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      decoration: Decorations.white2Card,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              formatMoney.format(widget.refillCurrent.price),
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
