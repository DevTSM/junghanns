import 'package:flutter/material.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/components/without_location.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/notifications.dart';
import 'package:provider/provider.dart';

import '../../preferences/global_variables.dart';

class Notificactions extends StatefulWidget {
  const Notificactions({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificactionsState();
}

class _NotificactionsState extends State<Notificactions> {
  late ProviderJunghanns provider;
  late List<NotificationModel> notifications;
  late Size size;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    notifications=[];
    isLoading = false;
    getData();
  }

  getData() async {
    List<NotificationModel> notificationsGet = await handler.retrieveNotification();
    //Provider.of<ProviderJunghanns>(context,listen: false).cleanPendingNotifications();
    setState(() {
      notifications.clear();
      notifications.addAll(notificationsGet);
    });
  }
  @override
  Widget build(BuildContext context) {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: ()=> getData(),
            child: SingleChildScrollView(
              child:_body()
            )
          ),
          Visibility(
            visible: isLoading, 
            child: const LoadingJunghanns()
          )
        ],
      )
    );
  }

  Widget _body(){
    return Container(
      height: size.height*.9,
      color: JunnyColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          provider.connectionStatus == 4
            ? const WithoutInternet()
            : provider.isNeedAsync
              ? const NeedAsync()
              : const SizedBox.shrink(),
          Visibility(
            visible: !provider.permission,
            child: const WithoutLocation()
          ),
          header(),
          const SizedBox(height: 15),
          Expanded(
            child: notifications.isNotEmpty 
              ? _listNototifications()
              : empty(context)
          )
        ],
      )
    );
  }
  
  Widget header() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checkDate(DateTime.now()),
                  style: TextStyles.blue19_7,
                ),
                Text(
                  "Notificaciones",
                  style: JunnyText.green24(FontWeight.w400, 16),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: Decorations.orangeBorder5,
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: prefs.nameRouteD,
                      style: TextStyles.white17_5
                    ),
                  ]
                )
              )
            )
          ),
        ]
      )
    );
  }
  
  Widget _listNototifications(){
    return FutureBuilder(
      future: handler.retrieveNotification(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<NotificationModel>> snapshot
      ) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              return NotificationCard(
                current: snapshot.data?[index]
                  ?? NotificationModel.fromState()
              );
            }
          );
        } else {
          return empty(context);
        }
      }
    );
  }
}
