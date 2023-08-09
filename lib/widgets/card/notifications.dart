import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

class NotificationCard extends StatelessWidget {
  NotificationModel current;
  NotificationCard({Key? key, required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: TextStyles.blue16_7,
              ),
              Row(
                    children: [
                      Expanded(child:Text(
                        "Descripcion: ${current.description}",
                        style: TextStyles.grey14_4,
                      )),
                    ],
                  ),
              Text(DateFormat('yyyy-MM-dd | HH:mm').format(current.date),
                  style: TextStyles.grey14_4),
            ],
          )),
        ],
      ),
    );
  }
}