import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
class SheetSelect extends StatelessWidget{
  Function update;
  List<Map<String, dynamic>> items;
  Map<String, dynamic> current;
  String title;
  SheetSelect({super.key,
    required this.update,
    required this.items,
    required this.current,
    required this.title
  });
  sheetSelect(BuildContext context) async {
  await showCupertinoModalPopup<int>(
    context: context,
    builder: (context) {
      return CupertinoActionSheet(
        actionScrollController: ScrollController(
          initialScrollOffset: 1.0, 
          keepScrollOffset: true
        ),
        actions: items.map((e) => _showItemType(e)).toList()
      );
    }
  );
}
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: Text(
            title,
            style: JunnyText.semiBoldBlueA1(15)
          ),
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: JunnyDecoration.whiteBox(15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    current["descripcion"],
                    style: TextStyles.blueJ15SemiBold,
                  )
                ),
                const Icon(
                  FontAwesomeIcons.caretDown,
                  color: JunnyColor.bluea4,
                )
              ],
            ),
          ),
          onTap: ()=>sheetSelect(context),
        )
      ],
    );
  }
  Widget _showItemType(Map<String, dynamic> current) {
  return GestureDetector(
    child: Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
      child: DefaultTextStyle(
        style: TextStyles.blueJ20Bold,
          child: Text(
            current["descripcion"],
          )
        )
      ),
      onTap: () {
        update(current);
      },
    );
  }
}

