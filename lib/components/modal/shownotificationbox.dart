import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/models/notification/notification_box.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';
class ShowNotificationBox extends StatelessWidget{
  final NotificationBox current;
  const ShowNotificationBox({Key? key,required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * .85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
              children: [
                AnimateIcon(
                  key: UniqueKey(),
                  onTap: () {},
                  iconType: IconType.continueAnimation,
                  height: 70,
                  width: 70,
                  color: JunnyColor.orange_255,
                  animateIcon: AnimateIcons.bell,
                ),
                Expanded(
                  child:Text(
                    current.title,
                    style: JunnyText.bluea4(FontWeight.bold, 22),
                    textAlign: TextAlign.center,
                  ),
                )
              ]
          ),
          Text(
              current.body,
              style: JunnyText.grey_255(FontWeight.w400, 15)
          ),
          Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Text(
                  DateFormat('yyyy-MM-dd | HH:mm').format(current.createdAt),
                  style: JunnyText.green24(FontWeight.w600, 12)
              )
          ),
          const SizedBox(height: 15),
          ButtonJunghannsLabel(
              width: double.infinity,
              fun: ()=> Navigator.pop(context),
              decoration: JunnyDecoration.orange255(12)
                  .copyWith(color: JunnyColor.bluea4),
              style: JunnyText.semiBoldBlueA1(16)
                  .copyWith(color: JunnyColor.white),
              label: "Aceptar"),
        ],
      ),
    );
  }
}

showNotificationBox(BuildContext context,NotificationBox current) async {
  final provider = Provider.of<ProviderJunghanns>(context, listen: false);
  await provider.readAndReceived(id: current.id.toString(), delivered: 'E', readed: 'S',);
  await provider.getNotificationBox();

  showDialog(
    context: context,
    builder: (_) =>
        AlertDialog(
            content: ShowNotificationBox(
                current: current
            )
        ),
  );
}