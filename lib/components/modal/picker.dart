import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
class Picker extends StatelessWidget{
  Function update;
  String current;
  String title;
  Picker({super.key,
    required this.update,
    required this.current,
    required this.title
  });
  
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
                    current,
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
          onTap: () async => update(await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now())
          ),
        )
      ],
    );
  }
}

