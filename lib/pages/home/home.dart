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
import 'package:intl/intl.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/dashboard.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/util/location.dart';
import 'package:provider/provider.dart';

import '../../services/store.dart';
import '../../widgets/modal/receipt_modal.dart';
import '../../widgets/modal/validation_modal.dart';

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
  late AutoSizeGroup group;
  late int atendidos;
  late int routeTotal;
  late int specials,
      specialsA,
      llama,
      llamaA,
      entrega,
      entregaA,
      rutaA,
      llamaCA,
      llamaC,
      secon;
  List specialData = [];

  @override
  void initState() {
    super.initState();
    getPermission();
    dashboardR = DashboardModel.fromPrefs();
    isLoading = false;
    isLoadingAsync = false;
    group = AutoSizeGroup();
    atendidos = 0;
    routeTotal = 0;
    specials = 0;
    specialsA = 0;
    entrega = 0;
    entregaA = 0;
    llama = 0;
    llamaA = 0;
    rutaA = 0;
    llamaC = 0;
    llamaCA = 0;
    secon = 0;
    getDashboarR();
    getAsync();
    _refreshTimer();
  }
  @override
  void dispose(){
    super.dispose();
  }

  getPermission() async {
    await Geolocator.requestPermission();
  }

  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    // Ahora fetchStockValidation devuelve un objeto ValidationModel
    provider.fetchStockValidation();
    provider.fetchStockDelivery();

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

  getDashboarR() async {
    Timer(const Duration(milliseconds: 1000), () async {
      if (provider.connectionStatus < 4) {
        setState(() {
          isLoading = true;
        });
        await getDashboarRuta(prefs.idRouteD, DateTime.now())
            .then((answer) async {
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
                log(" Get ${answer.body}");
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
      await Async(provider: provider).getStock();
      List<ProductModel> dataList = await handler.retrieveProducts();
      dataList.map((e) {
        var exits =
            dashboardR.stock.where((element) => element["id"] == e.idProduct);
        if (exits.isNotEmpty) {
          setState(() {
            exits.first["venta_local"] =
                int.parse((exits.first["stock"] ?? 0).toString()) -
                    int.parse((e.stock).toString());
          });
        }
      }).toList();
    });
  }

  getAsync() async {
    List<CustomerModel> value = await handler.retrieveUsers();
    value.map((e) {
      setState(() {
        switch (e.type) {
          case 2:
            specials++;
            break;
          case 3:
            secon++;
            break;
          case 4:
            llamaC++;
            break;
          case 5:
            entrega++;
            break;
          case 6:
            break;
          case 7:
          log(e.typeVisit);
            if (e.typeVisit == "ESPECIALES") {
              specialsA++;
            }
            if (e.typeVisit == "SEGUNDA") {
              llamaA++;
            }
            if (e.typeVisit == "RUTA") {
              rutaA++;
            }
            if (e.typeVisit == "CTE LLAMA C") {
              llamaCA++;
            }
            if (e.typeVisit == "CTE LLAMA") {
              llama++;
            }
            if (e.typeVisit == "ENTREGA") {
              entregaA++;
            }
            atendidos++;
            break;
            case 8:
            break;
          default:
            routeTotal++;
            break;
        }
      });
    }).toList();
    prefs.dataSale = true;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(
      children: [
        RefreshIndicator(
                onRefresh: () async {
                  dashboardR = DashboardModel.fromPrefs();
                  isLoading = false;
                  isLoadingAsync = false;
                  atendidos = 0;
                  routeTotal = 0;
                  specials = 0;
                  specialsA = 0;
                  entrega = 0;
                  entregaA = 0;
                  llama = 0;
                  llamaA = 0;
                  rutaA = 0;
                  llamaC = 0;
                  llamaCA = 0;
                  secon = 0;
                  getDashboarR();
                  getAsync();
                  _refreshTimer();
                },child:SingleChildScrollView(
        child:
                Container(
            height: size.height*1.01,
            color: ColorsJunghanns.lightBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.connectionStatus == 4
                          ? const WithoutInternet()
                          : provider.isNeedAsync
                              ? const NeedAsync()
                              : Container(),
                      deliveryMenZone(),
                      const SizedBox(
                        height: 20,
                      ),
                      customersZone()
                    ],
                  ),
                ))),
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
                  child: Text(
                          checkDate(DateTime.now()),
                          style: TextStyles.blue19_7,
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
                            "${routeTotal + specials + llamaC + entrega+secon}",
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
                          borderRadius: BorderRadius.circular(8),
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
              height: 10,
            ),
            Visibility(
                visible: prefs.lastBitacoraUpdate != "",
                child: Text(
                  "Última actualización: ${DateFormat('hh:mm a').format(prefs.lastBitacoraUpdate != "" ? DateTime.parse(prefs.lastBitacoraUpdate) : DateTime.now())}",
                  style: TextStyles.blue13It,
                )),
            const SizedBox(
              height: 10,
            ),
            item(
                "VISITAS",
                [
                  {
                    "type": "Ruta",
                    "atendidos": rutaA,
                    "faltantes": routeTotal + rutaA,
                  },
                  {
                    "type": "Especiales",
                    "atendidos": specialsA,
                    "faltantes": specials + specialsA,
                  },
                  {
                    "type": "Entregas",
                    "atendidos": entregaA,
                    "faltantes": entrega + entregaA,
                  },
                  {
                    "type": "C. Llama Conf.",
                    "atendidos": llamaCA,
                    "faltantes": llamaC + llamaCA,
                  },
                  {
                    "type": "C. Llama",
                    "atendidos": llama,
                    "faltantes": llama,
                  },
                  {
                    "type": "S. Vueltas",
                    "atendidos": llamaA,
                    "faltantes": secon+llamaA,
                  }
                ],
                Image.asset(
                  "assets/icons/iconCalendar.png",
                  width: size.width * .1,
                )),
            const SizedBox(
              height: 10,
            ),
            item(
                "ALMACÉN",
                dashboardR.stock
                    .map((e) => {
                          "type": e["desc"] ?? "",
                          "atendidos": e["venta_local"] ?? 0,
                          "faltantes": e["stock"] ?? 0
                        })
                    .toList(),
                Container()),
            const SizedBox(
              height: 70,
            ),
          ],
        ));
  }

  Widget item(
      String label, List<Map<String, dynamic>> description, Widget icon) {
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
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AutoSizeText(
                          "Tipo", 
                          style: JunnyText.grey_255(FontWeight.w600, 12),
                          maxLines: 1,
                        )
                      ),
                      Expanded(
                          child: AutoSizeText(
                        label == "ALMACÉN" ? "Total" : "Programadas",
                        style: JunnyText.grey_255(FontWeight.w600, 12),
                        group: group,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      )),
                      Expanded(
                          child: Text(
                        label == "ALMACÉN" ? "Vendidos" : "Atendidas",
                        style: JunnyText.grey_255(FontWeight.w600, 12),
                        textAlign: TextAlign.center,
                      ))
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              description.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: description
                          .map((e) => e["type"] != null
                            ? Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(e["type"],
                                          style: TextStyles.grey14_4)),
                                  Expanded(
                                      child: Text(
                                    e["faltantes"].toString(),
                                    style: TextStyles.grey14_4,
                                    textAlign: TextAlign.center,
                                  )),
                                  Expanded(
                                      child: Text(e["atendidos"].toString(),
                                          style: TextStyles.grey14_4,
                                          textAlign: TextAlign.center)),
                                ],
                              )
                              :const SizedBox.shrink()
                            )
                          .toList(),
                    )
                  : const SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Sin stock asignado",
                        style: TextStyles.blue16_4,
                        textAlign: TextAlign.center,
                      ),
                    )
            ],
          )),
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
          onTap: () async {
            Position? currentLocation =
                await LocationJunny().getCurrentLocation();
            setState(() {
              isLoadingAsync = true;
            });
            provider.asyncProcess = true;
            provider.isNeedAsync = false;
            /*provider.synchronizeListDelivery();*/
            
            Async async = Async(provider: provider);
            await async.initAsync().then((value) async {
              await handler.inserBitacora({
                "lat": (currentLocation != null ? currentLocation.latitude : 0),
                "lng": currentLocation != null ? currentLocation.longitude : 0,
                "date": DateTime.now().toString(),
                "status": value ? "1" : "0",
                "desc": jsonEncode({"text": "Sincronizacion Manual"})
              });
              setState(() {
                isLoading = false;
                isLoadingAsync = false;
              });
              getAsync();
            });
          },
        ));
  }
}
