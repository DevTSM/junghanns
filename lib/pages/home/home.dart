// ignore_for_file: avoid_unnecessary_containers
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/dashboard.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/pages/home/specials.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

import '../../services/store.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Size size;
  late DashboardModel dashboardR;
  late bool isLoading;
  late bool isLoadingAsync;
  late ProviderJunghanns provider;
  late int atendidos;
  late int routeTotal;
  late int liquit, specials,specialsA;

  @override
  void initState() {
    super.initState();
    getPermission();
    dashboardR = DashboardModel.fromPrefs();
    isLoading = false;
    isLoadingAsync = false;
    atendidos = 0;
    routeTotal = 0;
    liquit = 0;
    specials = 0;
    specialsA=0;
    getDashboarR();
    getAsync();
  }

  getPermission() async {
    await Geolocator.requestPermission();
  }

  getDashboarR() async {
    Timer(const Duration(milliseconds: 1000), () async {
      if (provider.connectionStatus < 4) {
        setState(() {
          isLoading = true;
        });
        await getDashboarRuta(prefs.idRouteD, DateTime.now()).then((answer) {
          setState(() {
            isLoading = false;
          });
          if (prefs.token != "") {
            if (answer.error) {
              Fluttertoast.showToast(
                msg: answer.message,
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            } else {
              setState(() {
                dashboardR = DashboardModel.fromService(answer.body);
                prefs.existStock=dashboardR.liquidStock;
                prefs.soldStock=dashboardR.liquidSales;
                prefs.statusRoute = answer.body["paro_de_ruta"] ?? "";
              });
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
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  getAsync() async {
    List<Map<String, dynamic>> dataList = await handler.retrieveSales();
    List<Map<String, dynamic>> dataList2 = await handler.retrieveStopOff();
    List<CustomerModel> value= await handler.retrieveUsers();
    log("total ___>${value.length}");
      value.map((e) {
        setState(() {
          switch (e.type) {
            case 2:
              specials++;
              routeTotal++;
              break;
            case 7:
            if(e.typeVisit=="ESPECIALES"){
              specialsA++;
            }
              atendidos++;
              break;
              case 6:
              break;
            default:
              routeTotal++;
              break;
          }
        });
      }).toList();
      log("-----------> $routeTotal");
    dataList.map((element) {
      List<dynamic> data = jsonDecode(element["saleItems"]);
      setState(() {
        data.map((e){
          if(e["id_producto"]==22){
            liquit+=int.parse(e["cantidad"].toString());
          }
        }).toList();
      });
    }).toList();
    prefs.dataSale = true;
  }

  // getStock() async {
  //   Timer(const Duration(milliseconds: 1000), () async {
  //     if (provider.connectionStatus < 4) {
  //       await getStockList(prefs.idRouteD).then((answer) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         if (answer.error) {
  //           Fluttertoast.showToast(
  //             msg: "Sin productos",
  //             timeInSecForIosWeb: 2,
  //             toastLength: Toast.LENGTH_LONG,
  //             gravity: ToastGravity.TOP,
  //             webShowClose: true,
  //           );
  //         } else {
  //           prefs.stock = jsonEncode(answer.body);
  //           List<ProductModel> productsList = [];
  //           answer.body.map((e) {
  //             productsList.add(ProductModel.fromServiceProduct(e));
  //           }).toList();
  //           if (productsList.isNotEmpty) {
  //             productsList
  //                 .sort(((a, b) => b.rank.length.compareTo(a.rank.length)));
  //           }
  //         }
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(
      children: [
        Container(
            height: double.infinity,
            color: ColorsJunghanns.lightBlue,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: provider.connectionStatus == 4,
                      child: const WithoutInternet()),
                  deliveryMenZone(),
                  const SizedBox(
                    height: 20,
                  ),
                  customersZone()
                ],
              ),
            )),
        isLoadingAsync
            ? const Align(
                alignment: Alignment.bottomCenter,
                child: SpinKitCircle(
                  color: ColorsJunghanns.blue,
                ))
            : buttonSync(),
        Visibility(visible: isLoading, child: const LoadingJunghanns())
      ],
    );
  }

  Widget deliveryMenZone() {
    return Container(
        decoration: Decorations.junghannsWater,
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Bienvenido",
            style: TextStyles.green22_4,
          ),
          Text(
            prefs.nameD,
            style: TextStyles.blue27_7,
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
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
                          "${routeTotal+specials} clientes para visitar",
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
                        const TextSpan(text: "", style: TextStyles.white27_7)
                      ])))),
            ],
          )),
        ]));
  }

  Widget customersZone() {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: ColorsJunghanns.lightBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Clientes atentidos",
              style: TextStyles.blue19_6,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  decoration: Decorations.blueBorder12,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        "assets/icons/icon1.png",
                        width: size.width * .1,
                      ),
                      Column(
                        children: [
                          Text(
                            "${routeTotal+specials}",
                            style: TextStyles.white40_7,
                          ),
                          const Text(
                            "En ruta",
                            style: TextStyles.white17_6,
                          )
                        ],
                      )
                    ],
                  ),
                )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                "assets/icons/iconCheck.png",
                                width: size.width * .1,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "$atendidos",
                                    style: TextStyles.blue40_7,
                                  ),
                                  const Text(
                                    "Atendidos",
                                    style: TextStyles.grey17_4,
                                  )
                                ],
                              )
                            ],
                          ),
                        ))),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            item(
                "Servicios Especiales",
                [
                  "${specials+specialsA} programados /",
                  " $specialsA Atentidos"
                ],
                Image.asset(
                  "assets/icons/iconCalendar.png",
                  width: size.width * .1,
                )),
            const SizedBox(
              height: 10,
            ),
            item(
                "Avance de venta",
                [
                  "${prefs.existStock} Líquidos existencia /",
                  " ${prefs.soldStock+liquit} Vendidos"
                ],
                Image.asset(
                  "assets/icons/iconWarehouse.png",
                  width: size.width * .1,
                ))
          ],
        ));
  }

  Widget item(String label, List<String> description, Widget icon) {
    return Container(
      decoration: Decorations.whiteBorder12,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 18),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyles.blue19_6),
              const SizedBox(
                height: 7,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: description[0], style: TextStyles.grey14_4),
                TextSpan(text: description[1], style: TextStyles.grey14_7)
              ]))
            ],
          )),
          icon
        ],
      ),
    );
  }

  Widget buttonSync() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          child: Container(
            height: 50,
            width: size.width * 0.5,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: Decorations.blueBorder30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.sync,
                  color: Colors.white,
                ),
                Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: AutoSizeText(
                      "Sincronizar",
                      style: TextStyles.white18Itw,
                      textAlign: TextAlign.center,
                    ))
              ],
            ),
          ),
          onTap: () {
            setState(() {
              isLoadingAsync = true;
            });
            provider.asyncProcess=true;
            Async async = Async(provider: provider);
            async
                .initAsync()
                .then((value) => setState((){
                  isLoading = false;
                  isLoadingAsync=false;
                  getAsync();}));
                  
          },
        ));
  }
}
