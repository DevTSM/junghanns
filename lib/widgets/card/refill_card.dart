import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';

import '../../styles/decoration.dart';
import '../../styles/text.dart';

class RefillCard extends StatefulWidget {
  final String icon;
  final int number;
  const RefillCard({Key? key, required this.icon, required this.number})
      : super(key: key);

  @override
  RefillCardState createState() => RefillCardState();
}

class RefillCardState extends State<RefillCard> {
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
                Expanded(flex: 4, child: imageRefill()),
                Expanded(flex: 2, child: textRefill()),
                Expanded(flex: 2, child: priceRefill()),
              ],
            )),
        onTap: () {
          setState(() {
            isSelect = !isSelect;
          });
        });
  }

  Widget imageRefill() {
    return Image.asset(
      widget.icon,
    );
  }

  Widget textRefill() {
    return Container(
      alignment: Alignment.center,
      child: Flexible(
          child: AutoSizeText(
        "Recarga \$${widget.number}.00",
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
              "\$${widget.number}.00",
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
