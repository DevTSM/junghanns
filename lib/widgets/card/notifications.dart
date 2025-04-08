import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/modal/shownotification.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

class NotificationCard extends StatelessWidget {
  NotificationModel current;
  NotificationCard({Key? key, required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showNotification(context,current),
    child:Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 10),
      child: Row(
        children: [
          ClipOval(
            child:Container(
              color: ColorsJunghanns.lighGrey,
              padding: const EdgeInsets.all(10),
            child: Image.asset(
              "assets/icons/menuOp5B.png",width: 30,color: ColorsJunghanns.white,),
          )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.name,
                  style: JunnyText.bluea4(current.status == 0
                    ? FontWeight.w800
                    : FontWeight.w500, 
                    14
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child:Text(
                        "Descripcion: ${current.description}",
                        style: JunnyText.grey_255(current.status == 0
                          ? FontWeight.w800
                          : FontWeight.w400, 
                          14
                        ),
                      )
                    ),
                  ],
                ),
                Text(
                  DateFormat('yyyy-MM-dd | HH:mm').format(current.date),
                  style: JunnyText.grey_255(current.status == 0
                    ? FontWeight.w800
                    : FontWeight.w400, 
                    14
                  ),
                ),
              ],
            )
          ),
          const SizedBox(width: 4),
          Visibility(
            visible: current.status == 0,
            child: ClipOval(
            child: Container(
              width: 7,
              height: 7,
              color: JunnyColor.red5c,
            ),
          )
          )
        ],
      ),
    )
    );
  }
}