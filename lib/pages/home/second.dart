import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/logout.dart';
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
  late ProviderJunghanns provider;
  late List<CustomerModel> customerList;
  late Size size;
  late bool isLoading;
  //
  late TextEditingController buscadorC;
  late List<CustomerModel> searchList;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    customerList = [];
    //
    buscadorC = TextEditingController();
    searchList = [];
    //
    getDataCustomerList();
  }

  getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      provider.permission = true;
    } else {
      provider.permission = false;
    }
  }

  getDataCustomerList() async {
    Timer(const Duration(milliseconds: 800), () async {
      if (provider.connectionStatus < 4) {
        customerList.clear();
        setState(() {
          isLoading = true;
        });
        await getListCustomer(prefs.idRouteD, DateTime.now(), "S")
            .then((answer) {
          setState(() {
            isLoading = false;
          });
          if (prefs.token != "") {
            if (answer.error) {
              Fluttertoast.showToast(
                msg: "Sin clientes en ruta",
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            } else {
              setState(() {
                answer.body.map((e) {
                  customerList
                      .add(CustomerModel.fromList(e, prefs.idRouteD, 3));
                }).toList();
                searchList = customerList;
              });
              getPermission();
            }
          } else {
            Fluttertoast.showToast(
              msg: "Las credenciales caducaron.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            Timer(const Duration(milliseconds: 2000), () async {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            });
          }
        });
      }
    });
  }

  funRefreshList() async {
    log("Refresh List");
    customerList.clear();
    await getListCustomer(prefs.idRouteD, DateTime.now(), "S").then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin clientes en ruta",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        answer.body.map((e) {
          customerList.add(CustomerModel.fromList(e, prefs.idRouteD, 3));
        }).toList();
        setState(() {
          searchList = customerList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    });
    return Stack(children: [
      RefreshIndicator(
          onRefresh: () async {
            log("Texto");
            if (provider.connectionStatus < 4) {
              funRefreshList();
            }
          },
          child: SizedBox(
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: provider.connectionStatus == 4,
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: ColorsJunghanns.red,
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: const Text(
                            "Sin conexión a internet",
                            style: TextStyles.white14_5,
                          ))),
                  Visibility(
                      visible: !provider.permission,
                      child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: ColorsJunghanns.red,
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: const Text(
                            "No has proporcionado permisos de ubicación",
                            style: TextStyles.white14_5,
                          ))),
                  header(),
                  const SizedBox(
                    height: 15,
                  ),
                  Visibility(
                      visible: provider.connectionStatus < 4 &&
                          customerList.isNotEmpty,
                      child: buscador()),
                  provider.connectionStatus < 4
                      ? customerList.isNotEmpty
                          ? Expanded(
                              child: SingleChildScrollView(
                                  child: Column(
                              children: searchList.map((e) {
                                return Column(children: [
                                  RoutesCard(
                                      icon: Container(
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(
                                              e.color
                                                  .toUpperCase()
                                                  .replaceAll("#", "FF"),
                                              radix: 16)),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        height: size.width * .14,
                                        width: size.width * .14,
                                        child: Image.asset(
                                            "assets/icons/userIcon.png"),
                                      ),
                                      customerCurrent: e),
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
                              "Sin clientes",
                              style: TextStyles.blue18SemiBoldIt,
                            )))
                      : Expanded(
                          child: FutureBuilder(
                              future: handler.retrieveUsersType(3),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<CustomerModel>> snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      itemCount: snapshot.data?.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Column(children: [
                                          RoutesCard(
                                              icon: Image.asset(
                                                "assets/icons/${snapshot.data![index].typeVisit == "RUTA" ? "user1" : snapshot.data![index].typeVisit == "SEGUNDA" ? "user3" : "user2"}.png",
                                                width: size.width * .14,
                                              ),
                                              customerCurrent:
                                                  snapshot.data![index]),
                                          Row(children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left:
                                                      (size.width * .07) + 15),
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
              ))),
      Visibility(visible: isLoading, child: const LoadingJunghanns())
    ]);
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 15, top: 10, bottom: size.height * .06),
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
                          checkDate(DateTime.now()),
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
                        TextSpan(
                            text: prefs.nameRouteD,
                            style: TextStyles.white17_5),
                      ])))),
            ],
          )),
    ]);
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
            style: TextStyles.blueJ15SemiBold,
            decoration: InputDecoration(
              hintText: "Buscar ...",
              hintStyle: TextStyles.grey15Itw,
              filled: true,
              fillColor: ColorsJunghanns.whiteJ,
              contentPadding: const EdgeInsets.only(left: 24),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(width: 1, color: ColorsJunghanns.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                  child: Icon(
                    Icons.search,
                    color: ColorsJunghanns.blue,
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
