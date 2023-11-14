import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
class Picker extends StatelessWidget{
  Function update;
  String current;
  String title;
  String error;
  bool isDay;
  bool isRequired;
  Picker({super.key,
    required this.update,
    required this.current,
    required this.title,
    required this.error,
    this.isDay=false,
    this.isRequired=false
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: isRequired
            ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: title,style: JunnyText.semiBoldBlueA1(15)),
                  TextSpan(text: "*",style: JunnyText.red5c(18))
                ]
              )
            )
            : Text(
            title,
            style: JunnyText.semiBoldBlueA1(15),
          ),
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: error!=""
              ? JunnyDecoration.whiteBox(15).copyWith(
                  border: Border.all(color: JunnyColor.red5c)
              )
              : JunnyDecoration.whiteBox(15),
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
          onTap: () async => isDay
            ? update(await showDatePicker(
              context: context, 
              initialDate: DateTime.now().subtract(const Duration(days:18250)), 
              firstDate: DateTime.now().subtract(const Duration(days:32850)), 
              lastDate: DateTime.now().subtract(const Duration(days:6602)))
            ): update(await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now())
            ),
        ),
        Visibility(
          visible: error!="",
          child: Container(
            padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
            child: Text(
              error,
              style: JunnyText.red5c(13)
            ),
          )
        ),
      ],
    );
  }
}

