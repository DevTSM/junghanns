import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';
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
  late int itemBar;

  @override
  void initState() {
    super.initState();
    sales = [];
    itemBar=1;
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
            provider.connectionStatus == 4
                ? const WithoutInternet()
                : provider.isNeedAsync
                    ? const NeedAsync()
                    : Container(),
            touchBar(),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: itemBar==1?FutureBuilder(
                    future: handler.retrieveSalesAll(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return cardDebug(snapshot.data?[index] ?? {});
                            });
                      } else {
                        return Container();
                      }
                    }):FutureBuilder(
                    future: handler.retrieveBitacora(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return cardBitacora(snapshot.data?[index] ?? {});
                            });
                      } else {
                        return Container();
                      }
                    }))
          ],
        ),
      ),
    );
  }
  Widget touchBar() => Row(
        children: [
          Column(
            children: [
              GestureDetector(
                child: Container(
                  width: (size.width - 20) / 2,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  height: 30,
                  child: Text(
                    "Ventas",
                    textAlign: TextAlign.center,
                    style: itemBar == 1
                        ? TextStyles.blue18SemiBoldIt
                        : TextStyles.grey17_4,
                  ),
                ),
                onTap: () {
                  setState(() {
                    itemBar = 1;
                  });
                },
              ),
              Container(
                width: (size.width - 20) / 2,
                height: 3,
                color: itemBar == 1
                    ? ColorsJunghanns.blue
                    : ColorsJunghanns.lightBlue,
              )
            ],
          ),
          Column(
            children: [
              GestureDetector(
                child: Container(
                    width: (size.width - 20) / 2,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    height: 30,
                    child: Text(
                      "Bitacora",
                      textAlign: TextAlign.center,
                      style: itemBar == 2
                          ? TextStyles.blue18SemiBoldIt
                          : TextStyles.grey17_4,
                    )),
                onTap: () {
                  setState(() {
                    itemBar = 2;
                  });
                },
              ),
              Container(
                width: (size.width - 20) / 2,
                height: 3,
                color: itemBar == 2
                    ? ColorsJunghanns.blue
                    : ColorsJunghanns.lightBlue,
              )
            ],
          ),
        ],
      );
  Widget cardDebug(Map<String, dynamic> data) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(
            text: TextSpan(children: [
              const TextSpan(text: "id Cliente: ", style: TextStyles.blue16_7),
              TextSpan(
                  text: data["idCustomer"].toString(),
                  style: TextStyles.blue19_7),
            ]),
            overflow: TextOverflow.ellipsis),
        const SizedBox(
          height: 5,
        ),
        Text(
          "Id registro: ${data["id"] ?? 0}",
          style: TextStyles.blue16_4,
        ),
        Text(
          "Productos: ${jsonDecode(data["saleItems"])}",
          style: TextStyles.blue16_4,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "Metodos: ${jsonDecode(data["paymentMethod"])}",
          style: TextStyles.blue16_4,
        ),
        data["fecha"] != null
            ? Text(
                "Hora venta: ${DateFormat('hh:mm:ss a').format(DateTime.parse(data["fecha"]))}",
                style: TextStyles.blue16_4,
              )
            : Container()
      ])),
      IconButton(
          onPressed: () {},
          icon: Icon(
            data["isError"] == -1
                ? Icons.delete_outline_rounded
                : data["isError"] == 1
                    ? Icons.close
                    : data["isUpdate"] == 1
                        ? Icons.check_circle_outline
                        : Icons.restart_alt_outlined,
            color: data["isError"] == -1 || data["isError"] == 1
                ? ColorsJunghanns.red
                : data["isUpdate"] == 1
                    ? ColorsJunghanns.green
                    : ColorsJunghanns.grey,
          ))
    ]);
  }
  Widget cardBitacora(Map<String, dynamic> data) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(
          height: 5,
        ),
        Text(
          "Id registro: ${data["id"] ?? 0}",
          style: TextStyles.blue16_4,
        ),
        Text(
          "Descripcion: ${jsonDecode((data["desc"]??{"test:""sin datos"}))}",
          style: TextStyles.blue16_4,
        ),
        const SizedBox(
          height: 5,
        ),
        data["date"] != null
            ? Text(
                "Hora registro: ${DateFormat('hh:mm:ss a').format(DateTime.parse(data["date"]))}",
                style: TextStyles.blue16_4,
              )
            : Container(),
            Divider(thickness: 1,
            color: ColorsJunghanns.green,)
      ])),
      // IconButton(
      //     onPressed: () {},
      //     icon: Icon(
      //       data["status"] == "0"
      //               ? Icons.close
      //               :  Icons.check_circle_outline,
      //       color: data["status"] == "0"
      //           ? ColorsJunghanns.red
      //           : ColorsJunghanns.green,
      //     ))
    ]);
  }
}
