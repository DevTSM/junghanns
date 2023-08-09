import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/components/without_location.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/notifications.dart';
import 'package:junghanns/widgets/card/routes.dart';
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
    List<NotificationModel> notificationsGet=await handler.retrieveNotification();
    setState(() {
      notifications.clear();
      notifications.addAll(notificationsGet);
    });
  }
  @override
  Widget build(BuildContext context) {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    return Stack(children: [
      RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: SizedBox(
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  provider.connectionStatus == 4? const WithoutInternet():provider.isNeedAsync?const NeedAsync():Container(),
                  Visibility(
                      visible: !provider.permission,
                      child: const WithoutLocation()),
                  header(),
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: notifications.map((e) => NotificationCard(current: e)).toList(),
                  )
                ],
              ))),
      Visibility(visible: isLoading, child: const LoadingJunghanns())
    ]);
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkDate(DateTime.now()),
                          style: TextStyles.blue19_7,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: Decorations.orangeBorder5,
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: prefs.nameRouteD,
                            style: TextStyles.white17_5),
                      ])))),
            ],
          )),
    ]);
  }
}
