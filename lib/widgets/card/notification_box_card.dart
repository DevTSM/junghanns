import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/notification/notification_box.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

import '../../components/modal/shownotificationbox.dart';

class NotificationBoxCard extends StatelessWidget {
  NotificationBox current;
  NotificationBoxCard({Key? key, required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => showNotificationBox(context,current),
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
                        current.title,
                        style: JunnyText.bluea4(current.read == false
                            ? FontWeight.w800
                            : FontWeight.w500,
                            14
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child:Text(
                                "Descripcion: ${current.body}",
                                style: JunnyText.grey_255(current.read == false
                                    ? FontWeight.w800
                                    : FontWeight.w400,
                                    14
                                ),
                              )
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd | HH:mm').format(current.createdAt),
                        style: JunnyText.grey_255(current.read == false
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
                  visible: current.read == false,
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