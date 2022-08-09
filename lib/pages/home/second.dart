import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';
import 'package:provider/provider.dart';

import '../../preferences/global_variables.dart';

class Seconds extends StatefulWidget {
  const Seconds({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondsState();
}

class _SecondsState extends State<Seconds> {
  //late ProviderJunghanns provider;
  late List<CustomerModel> customerList;
  late Size size;
  late bool isLoading;

  late DateTime today;
  late String todayText, dayText, monthText;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    customerList = [];
    today = DateTime.now();
    today.month < 10
        ? monthText = "0${today.month}"
        : monthText = "${today.month}";
    today.day < 10 ? dayText = "0${today.day}" : dayText = "${today.day}";
    todayText = "${today.year}$monthText$dayText";
    getDataCustomerList();
  }

  getDataCustomerList() async {
    customerList.clear();

    log("Fecha: $todayText");
    log("Ruta: ${prefs.idRouteD}");
    await getListCustomer(prefs.idRouteD, todayText, "S").then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin clientes en ruta",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        setState(() {
          isLoading = false;
        });
      } else {
        //provider.handler.deleteTable();
        //provider.handler.addColumn();
        setState(() {
          answer.body.map((e) {
            customerList.add(CustomerModel.fromList(e, prefs.idRouteD));
            //provider.handler.insertUser([customerList.last]);
          }).toList();
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    //provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.whiteJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.whiteJ,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menu.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Visibility(
                visible: provider.connectionStatus == 4,
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: ColorsJunghanns.grey,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: const Text(
                      "Sin conexion a internet",
                      style: TextStyles.white14_5,
                    ))),*/
            header(),
            const SizedBox(
              height: 20,
            ),
            //provider.connectionStatus < 4
            //   ?
            isLoading
                ? loading()
                : customerList.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                        children: customerList.map((e) {
                          return Column(children: [
                            RoutesCard(
                                icon: Image.asset(
                                  "assets/icons/${e.typeVisit == "RUTA" ? "user1" : e.typeVisit == "SEGUNDA" ? "user3" : "user2"}.png",
                                  width: size.width * .14,
                                ),
                                customerCurrent: e,
                                type: "S",
                                title: ["${e.idClient} - ", e.address],
                                description: e.name),
                            Row(children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: (size.width * .07) + 15),
                                color: ColorsJunghanns.grey,
                                width: .5,
                                height: 15,
                              )
                            ])
                          ]);
                        }).toList(),
                      )))
                    : Expanded(
                        child: Center(
                            child: Text(
                        "Sin clientes en ruta",
                        style: TextStyles.blue18SemiBoldIt,
                      )))
            /* : Expanded(
                    child: FutureBuilder(
                        future: provider.handler.retrieveUsers(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CustomerModel>> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(children: [
                                    RoutesCard(
                                        icon: Image.asset(
                                          "assets/icons/${snapshot.data![index].typeVisit == "RUTA" ? "user1" : snapshot.data![index].typeVisit == "SEGUNDA" ? "user3" : "user2"}.png",
                                          width: size.width * .14,
                                        ),
                                        customerCurrent: snapshot.data![index],
                                        title: [
                                          "${snapshot.data![index].idClient} - ",
                                          snapshot.data![index].address
                                        ],
                                        description:
                                            snapshot.data![index].name),
                                    Row(children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: (size.width * .07) + 15),
                                        color: ColorsJunghanns.grey,
                                        width: .5,
                                        height: 15,
                                      )
                                    ])
                                  ]);
                                });
                          } else {
                            return Container();
                          }
                        }))*/
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 10, top: 10, bottom: size.height * .08),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorsJunghanns.blueJ,
                  )),*/
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Ruta de trabajo",
                            style: TextStyles.blue27_7,
                          ),
                          Text(
                            "  Clientes segunda vuelta",
                            style: TextStyles.green15_4,
                          ),
                        ],
                      ))),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                child: Image.asset(
                  "assets/icons/workRoute.png",
                  width: size.width * .13,
                ),
                onTap: () {
                  showConfirmLogOut();
                },
              )
            ],
          )),
      Container(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkDate(today),
                          style: TextStyles.blue19_7,
                        ),
                        Text(
                          "${customerList.length} clientes para visitar",
                          style: TextStyles.grey14_4,
                        )
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
                        const TextSpan(
                            text: "Ruta  ", style: TextStyles.white17_5),
                        TextSpan(
                            text: prefs.idRouteD.toString(),
                            style: TextStyles.white27_7)
                      ])))),
            ],
          )),
    ]);
  }

  showConfirmLogOut() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: size.width * .75,
              decoration: Decorations.whiteS1Card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [textConfirmLogOut(), buttoms()],
              ),
            ),
          );
        });
  }

  Widget textConfirmLogOut() {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 15, bottom: 25),
        child: DefaultTextStyle(
            style: TextStyles.blueJ22Bold, child: const Text("Cerrar sesión")));
  }

  Widget buttoms() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buttomSale(
              "Si",
              () => () {
                    Navigator.pop(context);
                    funLogOut();
                  },
              Decorations.blueBorder12),
          buttomSale(
              "No",
              () => () {
                    Navigator.pop(context);
                  },
              Decorations.redCard),
        ],
      ),
    );
  }

  Widget buttomSale(String op, Function fun, BoxDecoration deco) {
    return GestureDetector(
      onTap: fun(),
      child: Container(
          alignment: Alignment.center,
          width: size.width * 0.22,
          height: size.width * 0.11,
          decoration: deco,
          child: DefaultTextStyle(
              style: TextStyles.white18SemiBoldIt,
              child: Text(
                op,
              ))),
    );
  }

  funLogOut() {
    log("LOG OUT");
    //-------------------------*** LOG OUT
    prefs.isLogged = false;
    prefs.idUserD = 0;
    prefs.idProfileD = 0;
    prefs.nameUserD = "";
    prefs.nameD = "";
    prefs.idRouteD = 0;
    prefs.nameRouteD = "";
    prefs.dayWorkD = "";
    prefs.dayWorkTextD = "";
    prefs.codeD = "";
    //--------------------------*********
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget loading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        height: MediaQuery.of(context).size.width * .30,
        width: MediaQuery.of(context).size.width * .30,
        child: const SpinKitDualRing(
          color: Colors.white70,
          lineWidth: 4,
        ),
      ),
    );
  }
}
