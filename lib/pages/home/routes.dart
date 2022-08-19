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

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  late ProviderJunghanns provider;
  late List<CustomerModel> customerList;
  late Size size;
  late bool isLoading;

  late DateTime today;
  late String todayText, dayText, monthText;
  //
  late TextEditingController buscadorC;
  late List<CustomerModel> searchList;

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
    //
    buscadorC = TextEditingController();
    searchList = [];
    //
    getDataCustomerList();
  }

  getDataCustomerList() async {
    customerList.clear();

    log("Fecha: $todayText");
    log("Ruta: ${prefs.idRouteD}");
    await getListCustomer(prefs.idRouteD, todayText, "R").then((answer) {
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
        provider.handler.deleteTable();
        //provider.handler.addColumn();
        answer.body.map((e) {
          customerList.add(CustomerModel.fromList(e, prefs.idRouteD));
          provider.handler.insertUser([customerList.last]);
        }).toList();

        searchList = customerList;

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
              visible: provider.connectionStatus == 4,
              child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: ColorsJunghanns.grey,
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: const Text(
                    "Sin conexion a internet",
                    style: TextStyles.white14_5,
                  ))),
          header(),
          const SizedBox(
            height: 15,
          ),
          isLoading
              ? Container()
              : customerList.isNotEmpty
                  ? buscador()
                  : Container(),
          provider.connectionStatus < 4
              ? isLoading
                  ? loading()
                  : customerList.isNotEmpty
                      ? Flexible(
                          child:
                              SingleChildScrollView(child: listCustomersAPI()))
                      : Expanded(
                          child: Center(
                              child: Text(
                          "Sin clientes en ruta",
                          style: TextStyles.blue18SemiBoldIt,
                        )))
              : Expanded(
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
                                      indexHome: 2,
                                      icon: Image.asset(
                                        "assets/icons/${snapshot.data![index].typeVisit == "RUTA" ? "user1" : snapshot.data![index].typeVisit == "SEGUNDA" ? "user3" : "user2"}.png",
                                        width: size.width * .14,
                                      ),
                                      type: "R",
                                      customerCurrent: snapshot.data![index],
                                      title: [
                                        "${snapshot.data![index].idClient} - ",
                                        snapshot.data![index].address
                                      ],
                                      description: snapshot.data![index].name),
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
                      }))
        ],
      ),
    );
  }

  Widget listCustomersAPI() {
    return Column(
      children: searchList.map((e) {
        return Column(children: [
          RoutesCard(
              indexHome: 2,
              icon: Container(
                decoration: BoxDecoration(
                  color: Color(int.parse(
                      e.color.toUpperCase().replaceAll("#", "FF"),
                      radix: 16)),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                height: size.width * .14,
                width: size.width * .14,
                child: Image.asset("assets/icons/userIcon.png"),
              ),
              customerCurrent: e,
              type: "R",
              title: ["${e.idClient} - ", e.address],
              description: e.name),
          Row(children: [
            Container(
              margin: EdgeInsets.only(left: (size.width * .07) + 15),
              color: ColorsJunghanns.grey,
              width: .5,
              height: 15,
            )
          ])
        ]);
      }).toList(),
    );
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 10, top: 10, bottom: size.height * .06),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            "  Clientes programados para visita",
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

  Widget buscador() {
    return Container(
        height: size.height * 0.06,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: TextFormField(
            controller: buscadorC,
            onEditingComplete: funSearch,
            onChanged: (value) => funEmpty(value),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.white18SemiBoldIt,
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorsJunghanns.blueJ,
              contentPadding: const EdgeInsets.only(left: 24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                  child: Icon(
                    Icons.search,
                    color: ColorsJunghanns.white,
                  )),
            )));
  }

  funEmpty(String value) {
    if (value == "") {
      setState(() {
        searchList = customerList;
      });
    }
  }

  funSearch() {
    log("Cliente : ${buscadorC.text}");

    if (buscadorC.text != "") {
      searchList = [];
      setState(() {
        for (var element in customerList) {
          if (element.name
              .toLowerCase()
              .startsWith(buscadorC.text.toLowerCase())) {
            searchList.add(element);
          } else {
            if (element.address
                .toLowerCase()
                .startsWith(buscadorC.text.toLowerCase())) {
              searchList.add(element);
            } else {
              if (element.idClient
                  .toString()
                  .toLowerCase()
                  .startsWith(buscadorC.text.toLowerCase())) {
                searchList.add(element);
              }
            }
          }
        }
      });
    } else {
      setState(() {
        searchList = customerList;
      });
    }
  }
}
