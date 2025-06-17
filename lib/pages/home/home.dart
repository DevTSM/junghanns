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
import 'package:junghanns/pages/chat/chat.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/chat_provider.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/util/location.dart';
import 'package:junghanns/widgets/modal/transfers_modal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/store.dart';
import '../../widgets/modal/receipt_modal.dart';
import '../../widgets/modal/validation_modal.dart';
import '../socket/socket_service.dart';

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
  bool isButtonEnabled = true;
  Timer? _countdownTimer;
  Duration remainingTime = Duration.zero;
  DateTime? lastSyncTime;



  @override
  void initState() {
    super.initState();
    print('entra al init y actualiza');
    //checkLastSyncTime();
    Future.delayed(Duration.zero, () {
      checkLastSyncTime();
    });
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
    checkLastSyncTime();
    super.dispose();
  }

   saveLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('lastSyncTime', now.millisecondsSinceEpoch);
  }

  checkLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMillis = prefs.getInt('lastSyncTime');

    if (lastSyncMillis != null) {
      final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
      final elapsed = DateTime.now().difference(lastSyncTime);
      print("Última sincronización: $lastSyncTime, tiempo transcurrido: ${elapsed.inMinutes} minutos");

      if (elapsed < Duration(minutes: 10)) {
        if (!mounted) return;
        setState(() {
          isButtonEnabled = false;
          remainingTime = Duration(minutes: 10) - elapsed;
        });
        startCountdown();
      } else {
        if (!mounted) return;
        setState(() {
          isButtonEnabled = true;
        });
      }
    } else {
      print("No se ha encontrado un registro de sincronización anterior.");
    }
  }

  void startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime -= Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        checkLastSyncTime();
      }
    });
  }

  getPermission() async {
    await Geolocator.requestPermission();
  }

  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await checkLastSyncTime();
    await _refreshTransfers();

    await provider.fetchStockValidation();
    await provider.fetchStockDelivery();

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

  Future<void> _refreshTransfers() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    await provider.fetchValidation();

    final filteredDataTranfers = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Ruta" && validation.typeValidation == 'T' && validation.idRoute != prefs.idRouteD;
    }).toList();

    // Verificar si hay datos filtrados
    setState(() {
      if (filteredDataTranfers.isNotEmpty) {
        specialData = filteredDataTranfers;
        showTransferModal(context);
      } else {
        specialData = [];
      }
    });
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
            ///Cerrar la conecxión con el socket si se caducan las credenciales
            SocketService().disconnect();
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
      log(''' =======> 
      ${dataList.toString()}''');
      dataList.map((e) {
        var exits =
            dashboardR.stock.where((element) => element["id"] == e.idProduct);
        if (exits.isNotEmpty) {
          setState(() {
            print({
              "nombre": exits.first["desc"],
              "stock get":exits.first["stock"],
              "stockLocal":e.stock,
              "ventaLocal":int.parse((exits.first["stock"] ?? 0).toString()) -
                int.parse((e.stock).toString())
            });
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

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            color: JunnyColor.blueA1,
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
              checkLastSyncTime();
              _refreshTimer();
            },
            child: SingleChildScrollView(
              child: Container(
                height: size.height * 1.01,
                color: ColorsJunghanns.lightBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    provider.connectionStatus == 4 ? const WithoutInternet() : provider.isNeedAsync ? const NeedAsync() : Container(),
                    deliveryMenZone(),
                    const SizedBox(height: 20),
                    customersZone(),
                  ],
                ),
              ),
            ),
          ),
          isLoadingAsync ? const Align(alignment: Alignment.bottomCenter, child: SpinKitCircle(color: ColorsJunghanns.blue)) : buttonSync(),
          Visibility(visible: isLoading, child: const LoadingJunghanns())
        ],
      ),
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
                          "atendidos": e["venta_local"] ?? 0,//vendidos
                          "faltantes": e["stock"] ?? 0 //total
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
        onTap: isButtonEnabled
            ? () async {
          print("Botón sincronizar presionado");

          setState(() {
            isButtonEnabled = false;
          });

          Position? currentLocation = await LocationJunny().getCurrentLocation();
          provider.asyncProcess = true;
          provider.isNeedAsync = false;

          Async async = Async(provider: provider);
          await async.initAsync().then((value) async {
            await handler.inserBitacora({
              "lat": currentLocation?.latitude ?? 0,
              "lng": currentLocation?.longitude ?? 0,
              "date": DateTime.now().toString(),
              "status": value ? "1" : "0",
              "desc": jsonEncode({"text": "Sincronizacion Manual"})
            });
            await saveLastSyncTime();
            startCountdown();
            getAsync();
            isButtonEnabled = false;
          });
        }
            : null,

        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.5,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: isButtonEnabled
              ? Decorations.blueBorder30
              : Decorations.greyBorder30,
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
                  isButtonEnabled
                      ? "Sincronizar"
                      : "Espera ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: TextStyles.white18Itw,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
