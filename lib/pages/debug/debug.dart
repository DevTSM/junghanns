import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/components/without_location.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';
import 'package:provider/provider.dart';

import '../../preferences/global_variables.dart';

class Debug extends StatefulWidget {
  const Debug({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DebugState();
}

class _DebugState extends State<Debug> {
  late ProviderJunghanns provider;
  late List<CustomerModel> sales;
  late Size size;

  @override
  void initState() {
    super.initState();
    sales = [];
    getDataSales();
  }

  getDataSales() async {}

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    });
    return Scaffold(
        appBar: AppBar(
            backgroundColor: ColorsJunghanns.whiteJ,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: ColorsJunghanns.whiteJ,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.dark),
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: ColorsJunghanns.blue,
                ))),
        body: Container(
          padding: const EdgeInsets.all(10),
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                provider.connectionStatus == 4? const WithoutInternet():provider.isNeedAsync?const NeedAsync():Container(),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                    child: FutureBuilder(
                        future: handler.retrieveSalesAll(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (BuildContext context, int index) {
                                  SaleModel item=SaleModel.fromDataBase(snapshot.data![index]);
                                  return Row(children: [
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                      RichText(
                                          text: TextSpan(
                                            children: [
                                            const TextSpan(
                                                text: "id Cliente: ",
                                                style: TextStyles.blue16_7),
                                            TextSpan(
                                                text: snapshot.data?[index]
                                                        ["idCustomer"]
                                                    .toString(),
                                                style: TextStyles.blue19_7),
                                          ]),
                                          overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 5,),
                                        Text(
                                              "Id registro: ${snapshot.data?[index]
                                                        ["id"]??0}",
                                              style: TextStyles.blue16_4,
                                            ),
                                          Text(
                                              "Productos: ${jsonDecode(snapshot.data?[index]
                                                        ["saleItems"])}",
                                              style: TextStyles.blue16_4,
                                            ),
                                        const SizedBox(height: 5,),
                                          Text(
                                              "Metodos: ${jsonDecode(snapshot.data?[index]
                                                        ["paymentMethod"])}",
                                              style: TextStyles.blue16_4,
                                            ),
                                            snapshot.data?[index]
                                                        ["fecha"]!=null?Text(
                                              "Hora venta: ${DateFormat('hh:mm:ss a').format(DateTime.parse(snapshot.data?[index]
                                                        ["fecha"]))}",
                                              style: TextStyles.blue16_4,
                                            ):Container()
                                      
                                    ])),
                                    IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            snapshot.data?[index]["isUpdate"] ==
                                                    1
                                                ? Icons.check_circle_outline
                                                : Icons.restart_alt_outlined,
                                            color: snapshot.data?[index]
                                                        ["isUpdate"] ==
                                                    1
                                                ? ColorsJunghanns.green
                                                : ColorsJunghanns.grey,
                                          ))
                                  ]);
                                });
                          } else {
                            return Container();
                          }
                        }))
              ],
            ),
          ),);
  }
}
