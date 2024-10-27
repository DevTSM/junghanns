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
    getData();
    _refreshTimer();
  }
  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    // Ahora fetchStockValidation devuelve un objeto ValidationModel
    provider.fetchStockValidation();

// Filtrar los datos según las condiciones especificadas
    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
    }).toList();


// Verificar si hay datos filtrados
    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;  // Asigna los datos filtrados a specialData
        // Imprimir el contenido de specialData para confirmarlo
        print('Contenido de specialData (filtrado): $specialData');
        print('Llama al modal');
        showValidationModal(context);
      } else {
        specialData = [];  // Si no hay datos que cumplan las condiciones, asignar un arreglo vacío
        print('No se encontraron datos que cumplan las condiciones');
      }
    });

    if (provider.validationList.first.status =='P' && provider.validationList.first.valid == 'Ruta'){
      showReceiptModal(context);
    }
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
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ruta de trabajo",
                style: TextStyles.blue27_7,
              ),
              const Text(
                "  Notificaciones",
                style: TextStyles.green15_4,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      checkDate(DateTime.now()),
                      style: TextStyles.blue19_7,
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
            ],
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
          return  RefreshIndicator(
            onRefresh: ()=> getData(),
            child: ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return NotificationCard(
                  current: snapshot.data?[index]
                    ?? NotificationModel.fromState()
                );
              }
            )
          );
        } else {
          return empty(context);
        }
      }
    );
  }
}
