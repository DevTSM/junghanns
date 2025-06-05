import 'package:flutter/material.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/components/without_location.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/models/notification/notification_box.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

import '../../preferences/global_variables.dart';
import '../../widgets/card/notification_box_card.dart';
import '../../widgets/modal/receipt_modal.dart';
import '../../widgets/modal/validation_modal.dart';

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
  List specialData = [];

  @override
  void initState() {
    super.initState();
    notifications=[];
    isLoading = false;
    provider = Provider.of<ProviderJunghanns>(context, listen: false);
    getData();
    _refreshTimer();
  }
  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    provider.fetchStockValidation();

    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
    }).toList();

    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;
        showValidationModal(context);
      } else {
        specialData = [];
      }
    });

    if (provider.validationList.first.status =='P' && provider.validationList.first.valid == 'Ruta'){
      showReceiptModal(context);
    }
  }

  getData() async {
    provider.getNotificationBox();
    List<NotificationModel> notificationsGet = await handler.retrieveNotification();
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
      height: size.height * .9,
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
          //const SizedBox(height: 10),
          Expanded(
            child: provider.notificationBokList.isNotEmpty
              ? notificationScreen()/*_listNototifications()*/
              : empty(context)
          ),
          const SizedBox(height: 63),
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
                const Text(
                  "Notificaciones",
                  style: TextStyles.blue24_5,
                ),
                Text(
                  checkDate(DateTime.now()).toUpperCase(),
                  style: TextStyles.grey19_5.copyWith(height: 0.9), // ¡Clave!
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: Decorations.greenBorder5,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    prefs.nameRouteD,
                    style: TextStyles.white17_5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget notificationScreen() {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          return AnimatedBuilder(
            animation: tabController.animation!,
            builder: (context, _) {
              final titles = ['Todos', 'No leídos', 'Leídos'];
              final icons = [
                Icons.notifications,
                Icons.mark_email_unread,
                Icons.mark_email_read
              ];

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isSelected = tabController.animation!.value.round() == index;

                      return GestureDetector(
                        onTap: () => tabController.animateTo(index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? ColorsJunghanns.blueJ : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icons[index],
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                titles[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[800],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _listNotifications(filter: 'all'),
                        _listNotifications(filter: 'unread'),
                        _listNotifications(filter: 'read'),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _listNotifications({required String filter}) {
    return FutureBuilder(
      future: handler.retrieveNotification(),
      builder: (BuildContext context, AsyncSnapshot<List<NotificationModel>> snapshot) {
        final provider = Provider.of<ProviderJunghanns>(context);
        final list = provider.notificationBokList;

        List<NotificationBox> filteredList = [];

        if (snapshot.hasData) {
          final allList = [...list];

          filteredList = switch (filter) {
            'unread' => allList.where((n) => !n.read).toList(),
            'read' => allList.where((n) => n.read).toList(),
            _ => allList,
          };

          if (filteredList.isEmpty) return empty(context);

          return RefreshIndicator(
            onRefresh: () => getData(),
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return NotificationBoxCard(current: filteredList[index]);
              },
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
