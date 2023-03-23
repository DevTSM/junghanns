// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, must_be_immutable
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:location/location.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/address/edit_address.dart';
import 'package:junghanns/pages/shop/shopping_cart.dart';
import 'package:junghanns/pages/shop/shopping_cart_refill.dart';
import 'package:junghanns/pages/shop/stops.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/balance.dart';
import 'package:junghanns/widgets/card/sales.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../services/auth.dart';

class DetailsCustomer2 extends StatefulWidget {
  CustomerModel customerCurrent;
  String type;
  int indexHome;
  DetailsCustomer2(
      {Key? key,
      required this.customerCurrent,
      required this.type,
      required this.indexHome})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _DetailsCustomer2State();
}

class _DetailsCustomer2State extends State<DetailsCustomer2> {
  late ProviderJunghanns provider;
  late dynamic pickedImageFile;
  late List<ConfigModel> configList;
  late List<AuthorizationModel> authList;
  late LocationData currentLocation;
  late Size size;
  late double dif;
  late bool isRange;
  late bool isLoading, isLoadingHistory, isLoadingRange;

  @override
  void initState() {
    super.initState();
    pickedImageFile = null;
    configList = [];
    authList = [];
    dif = 0;
    isRange = false;
    isLoading = true;
    isLoadingHistory = false;
    isLoadingRange = false;
    currentLocation = LocationData.fromMap({});
    checkToken();
  }

  checkToken() async {
    await getDetailsCustomer(widget.customerCurrent.id, widget.type)
        .then((answer) async {
      setState(() {
        isLoading = false;
      });
      if (!answer.error) {
        setState(() {
          widget.customerCurrent.setData=answer.body;
          handler.updateUser(widget.customerCurrent);
        });
      }
    });
    setCurrentLocation();
    getHistory();
  }

  //deshabilitado
  getDataDetails() async {
    Timer(const Duration(milliseconds: 1000), () async {
      if (provider.connectionStatus < 4) {
        setState(() {
          isLoading = true;
        });
        await getDetailsCustomer(widget.customerCurrent.id, widget.type)
            .then((answer) async {
          setState(() {
            isLoading = false;
          });
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
              widget.customerCurrent = CustomerModel.fromService(answer.body,
                  widget.customerCurrent.id, widget.customerCurrent.type);
            });
          }
          getMoney();
          setCurrentLocation();
          getHistory();
        });
      } else {
        setState(() {
          isLoading = false;
        });
        setCurrentLocation();
      }
    });
  }

  getMoney() {
    getMoneyCustomer(widget.customerCurrent.idClient).then((answer) {
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
          widget.customerCurrent
              .setMoney(double.parse((answer.body["saldo"] ?? 0).toString()));
        });
      }
    });
  }
  // ---------
  setCurrentLocation() async {
    try {
      setState(() {
        isLoadingRange = true;
      });
      Location locationInstance = Location();
      PermissionStatus permission = await locationInstance.hasPermission();
      if (permission == PermissionStatus.granted) {
        provider.permission = true;
        locationInstance.changeSettings(accuracy: LocationAccuracy.high);
        if (await locationInstance.serviceEnabled()) {
          provider.permission = true;
          currentLocation = await locationInstance
              .getLocation()
              .timeout(const Duration(seconds: 15));
          await funCheckDistance(currentLocation);
        } else {
          provider.permission = false;
          Fluttertoast.showToast(
              msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor: ColorsJunghanns.red);
        }
      } else {
        log("permission ${permission.toString()}");
        provider.permission = false;
        isRange = false;
      }
      setState(() {
        isLoadingRange = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRange = false;
      });
      Fluttertoast.showToast(
          msg: "Tiempo de espera superado, vuelve a intentarlo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }
  
  funCheckDistance(LocationData currentLocation) async {
    try {
      if (provider.connectionStatus < 4) {
        await getConfig(widget.customerCurrent.idClient).then((answer) {
          if (answer.error) {
            Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
          } else {
            for (var item in answer.body) {
              configList.add(ConfigModel.fromService(item));
              //log("-------- ${configList.length} ");
            }
            setState(() {
              dif = calculateDistance(
                      widget.customerCurrent.lat,
                      widget.customerCurrent.lng,
                      currentLocation.latitude,
                      currentLocation.longitude) *
                  1000;
              isRange = dif <= configList.last.valor;
            });
          }
        });
      } else {
        setState(() {
          dif = calculateDistance(
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng,
                  currentLocation.latitude,
                  currentLocation.longitude) *
              1000;
          isRange = dif <=
              (widget.customerCurrent.configList.isNotEmpty
                  ? widget.customerCurrent.configList.last.valor
                  : 0);
        });
      }
    } catch (e) {
      log("***ERROR -- $e");
      Fluttertoast.showToast(
          msg: "Tiempo de espera superado, vuelve a intentarlo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }
  
  getHistory() async {
    setState(() {
      isLoadingHistory = true;
    });
    await getHistoryCustomer(widget.customerCurrent.idClient).then((answer) {
      log("---------History ${answer.body}");
      setState(() {
        isLoadingHistory = false;
      });
      if (!answer.error) {
        setState(() {
          widget.customerCurrent.setHistory(answer.body);
          handler.updateUser(widget.customerCurrent);
        });
      }
    });
  }

  getAuth() async {
    authList.clear();
      await getAuthorization(widget.customerCurrent.idClient, prefs.idRouteD)
          .then((answer) {
        if (!answer.error){
          answer.body
              .map((e) => authList.add(AuthorizationModel.fromService(e)))
              .toList();
        }
      });
      widget.customerCurrent.auth.map((e) => authList.add(e)).toList();
  }

  showSelectPR() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              width: size.width * .75,
              height: size.height * .24,
              decoration: Decorations.lightBlueS1Card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ButtonJunghanns(
                        isIcon: true,
                        icon: Image.asset(
                          "assets/icons/shopP2.png",
                          width: size.width * 0.14,
                        ),
                        fun: () => navigatorShopping(),
                        decoration: Decorations.blueBorder12,
                        style: TextStyles.white14_5,
                        label: "Productos"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: ButtonJunghanns(
                          isIcon: true,
                          icon: Image.asset("assets/icons/shopR1.png",
                              width: size.width * 0.14),
                          fun: () => navigatorShoppingRefill(),
                          decoration: Decorations.whiteSblackCard,
                          style: TextStyles.blue16_4,
                          label: "Recargas"))
                ],
              ),
            ),
          );
        });
  }

  navigatorShopping() async {
    Navigator.pop(context);
    try {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => ShoppingCart(
                    customerCurrent: widget.customerCurrent,
                    authList: authList.isEmpty ? authList : [authList.first],
                  ))).then(
          (value) => setState((){
            widget.customerCurrent;
          }));
    } catch (e) {
      log(e.toString());
    }
  }

  navigatorShoppingRefill() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ShoppingCartRefill(
                  customerCurrent: widget.customerCurrent,
                ))).then((value) =>setState(() {}));
  }

  funCheckDistanceSale(bool isSale) async {
    setState(() {
      isLoading = true;
    });
    await setCurrentLocation();
    await getAuth();
    setState(() {
      isLoading = false;
    });
    if (isRange) {
      //TODO:pruebas if(true){
      if (isSale) {
        showSelectPR();
      } else {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => Stops(
                      customerCurrent: widget.customerCurrent,
                      distance: (configList.isNotEmpty
                          ? configList.last.valor
                          : 0))));
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Estás a ${dif.ceil()} mtrs del domicilio",
        timeInSecForIosWeb: 16,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  funCurrentLocation() {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => EditAddress(
                lat: widget.customerCurrent.lat,
                lng: widget.customerCurrent.lng)));
  }

  _pickImage(int type) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.getImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery,
        maxHeight: 1500,
        maxWidth: 1500,
        imageQuality: 50,
      );
      setState(() {
        pickedImageFile = File(pickedImage!.path);
      });

      if (pickedImageFile != null) {
        final img = await pickedImage!.readAsBytes();
        File fileData =
            File.fromRawPath(img.buffer.asUint8List(0, img.lengthInBytes));
        var multipartFile = http.MultipartFile.fromBytes(
          'image',
          img.buffer.asUint8List(),
          filename: 'avatar.png', // use the real name if available, or omit
          contentType: MediaType('image', 'png'),
        );
        await updateAvatar(multipartFile,
            widget.customerCurrent.idClient.toString(), "SANDBOX");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg:
            "No fue posible ${type == 1 ? "abrir la camara" : "abrir la galeria"},por favor revisa los permisos e intentelo mas tarde.",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: ColorsJunghanns.red,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  funGoMaps() async {
    log("Go Maps");
    if (widget.customerCurrent.lat != 0 && widget.customerCurrent.lng != 0) {
      log("Go Maps Yes");
      var map = await MapLauncher.isMapAvailable(MapType.google);
      if (map ?? false) {
        log(" lat ->${widget.customerCurrent.lat} long ->${widget.customerCurrent.lng}");
        await MapLauncher.showMarker(
          mapType: MapType.google,
          coords:
              Coords(widget.customerCurrent.lat, widget.customerCurrent.lng),
          title: widget.customerCurrent.name,
          description: "",
        );
      } else {
        log("Go Maps Not");
        Fluttertoast.showToast(
          msg: "Sin mapa disponible",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    } else {
      log("No LAT y No LNG");
      Fluttertoast.showToast(
        msg: "Sin coordenadas",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    provider = Provider.of<ProviderJunghanns>(context);
    return !provider.asyncProcess
        ? Stack(children: [
            Scaffold(
              appBar: AppBar(
                leadingWidth: 30,
                backgroundColor: ColorsJunghanns.blueJ,
                systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: ColorsJunghanns.blueJ,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.light),
                leading: Container(),
                elevation: 0,
              ),
              backgroundColor: ColorsJunghanns.lightBlue,
              body: refreshScroll(),
              bottomNavigationBar: bottomBar(() {}, widget.indexHome,
                  isHome: false, context: context),
            ),
            Visibility(visible: isLoading, child: const LoadingJunghanns())
          ])
        : Scaffold(
            body: Stack(
            children: [
              Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                    Color.fromARGB(255, 244, 252, 253),
                    Color.fromARGB(255, 206, 240, 255)
                  ],
                          stops: [
                    0.2,
                    0.8
                  ],
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter))),
              Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/junghannsLogo.png"),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(provider.labelAsync),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          child: LinearProgressBar(
                            minHeight: 7,
                            maxSteps: provider.totalAsync,
                            progressType: LinearProgressBar
                                .progressTypeLinear, // Use Linear progress
                            currentStep: provider.currentAsync,
                            progressColor: ColorsJunghanns.green,
                            backgroundColor: ColorsJunghanns.grey,
                          ))
                    ]),
              ),
            ],
          ));
  }

  Widget refreshScroll() {
    return RefreshIndicator(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              Visibility(
                  visible: provider.connectionStatus == 4,
                  child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      color: ColorsJunghanns.red,
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: const Text(
                        "Sin conexion a internet",
                        style: TextStyles.white14_5,
                      ))),
              balances(),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        onRefresh: () async {
          getMoney();
          setCurrentLocation();
        });
  }

  Widget header() {
    return Container(
      color: ColorsJunghanns.blue,
      padding: EdgeInsets.only(
          right: 15, left: 23, top: 5, bottom: size.height * .03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: ColorsJunghanns.white,
              )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: ColorsJunghanns.green,
                      size: 28,
                    ),
                    Expanded(
                        child: AutoSizeText(
                      widget.customerCurrent.address,
                      style: TextStyles.white20SemiBoldIt,
                    ))
                  ],
                ),
                onTap: () => funGoMaps(),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      text: "Referencia de domicilio: ",
                      style: TextStyles.green16Itw,
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.customerCurrent.referenceAddress,
                            style: TextStyles.white16SemiBoldIt),
                      ],
                    ),
                  )),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: "${widget.customerCurrent.idClient}",
                  style: TextStyles.green18Itw,
                ),
                TextSpan(
                  text: "  |  ",
                  style: TextStyles.white60It18,
                ),
                TextSpan(
                  text: widget.customerCurrent.name,
                  style: TextStyles.white15It,
                )
              ]))
            ],
          )),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
              onTap: () => _pickImage(1),
              child: Image.asset(
                "assets/icons/photo.png",
                width: size.width * .13,
              ))
        ],
      ),
    );
  }

  Widget balances() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .01),
      child: Column(
        children: [
          //photoCard(),
          const SizedBox(
            height: 20,
          ),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
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
                              widget.customerCurrent.category,
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
                                text: widget.customerCurrent.nameRoute,
                                style: TextStyles.white17_5),
                          ])))),
                ],
              )),
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: Decorations.lightBlueBorder5,
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/invoice${widget.customerCurrent.invoice ? "Green" : "Red"}.png",
                      width: 40,
                    ),
                    Text(
                      widget.customerCurrent.invoice
                          ? "Solicita Factura"
                          : "No Solicita Factura",
                      style: TextStyles.grey14_4,
                    )
                  ],
                )),
                SizedBox(
                  width: widget.customerCurrent.invoice ? 10 : 0,
                ),
                Visibility(
                    visible: widget.customerCurrent.invoice,
                    child: Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      alignment: Alignment.center,
                      decoration: Decorations.greenBorder5,
                      child: const Text(
                        "Datos de Facturacón",
                        style: TextStyles.white17_5,
                      ),
                    )))
              ],
            ),
          ),
          SizedBox(
            height: widget.customerCurrent.descServiceS != "" ? 15 : 0,
          ),
          Visibility(
              visible: widget.customerCurrent.descServiceS != "",
              child: observation("Descripción de servicio",
                  widget.customerCurrent.descServiceS)),
          const SizedBox(
            height: 10,
          ),
          observation(
              "Observaciones de servicio", widget.customerCurrent.observation),
          const SizedBox(
            height: 10,
          ),
          Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: itemBalance("liquitIcon.png", "Precio Liquido",
                          widget.customerCurrent.priceLiquid, size.width - 40)),
                  Expanded(
                      child: itemBalance("cashIcon.png", "Monedero",
                          widget.customerCurrent.purse, size.width - 40)),
                  Expanded(
                      child: itemBalance("creditIcon.png", "Por cobrar",
                          widget.customerCurrent.byCollect, size.width - 40))
                ],
              )),
          const SizedBox(
            height: 15,
          ),
          Visibility(
              visible: widget.customerCurrent.notifS != "",
              child: observation(
                  "Notificación de servicio", widget.customerCurrent.notifS)),
          SizedBox(
            height: widget.customerCurrent.notifS != "" ? 15 : 0,
          ),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: isLoadingRange
                  ? const SpinKitCircle(
                      color: ColorsJunghanns.blue,
                    )
                  : isRange
                      ? prefs.statusRoute == "INRT" ||
                              prefs.statusRoute == "FNCM"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                    child: ButtonJunghanns(
                                        decoration: Decorations.greenBorder5,
                                        style: TextStyles.white17_5,
                                        fun: () {
                                          funCheckDistanceSale(true);
                                        },
                                        isIcon: true,
                                        icon: Image.asset(
                                          "assets/icons/shoppingCardWhiteIcon.png",
                                          height: 30,
                                        ),
                                        label: "Venta")),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: ButtonJunghanns(
                                        decoration: Decorations.whiteBorder5Red,
                                        style: TextStyles.red17_6,
                                        fun: () {
                                          funCheckDistanceSale(false);
                                        },
                                        isIcon: true,
                                        icon: Container(
                                          width: 0,
                                          height: 30,
                                        ),
                                        label: "Parada"))
                              ],
                            )
                          : prefs.statusRoute == "INCM"
                              ? ButtonJunghanns(
                                  fun: () async {
                                    if (provider.connectionStatus < 4) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await setInitRoute(
                                              currentLocation.latitude!,
                                              currentLocation.longitude!,
                                              status: "fin_comida")
                                          .then((answer) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (answer.error) {
                                          Fluttertoast.showToast(
                                            msg:
                                                "No fue posible continuar la ruta, revisa tu conexion a internet",
                                            timeInSecForIosWeb: 2,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP,
                                            webShowClose: true,
                                          );
                                        } else {
                                          setState(() {
                                            prefs.statusRoute = "FNCM";
                                          });
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        prefs.statusRoute = "FNCM";
                                      });
                                    }
                                  },
                                  decoration: Decorations.greenBorder5,
                                  style: TextStyles.white17_6,
                                  label: "Continuar ruta")
                              : ButtonJunghanns(
                                  fun: () async {
                                    if (provider.connectionStatus < 4) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await setInitRoute(
                                              currentLocation.latitude!,
                                              currentLocation.longitude!)
                                          .then((answer) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (answer.error) {
                                          Fluttertoast.showToast(
                                            msg:
                                                "No fue posible iniciar la ruta, revisa tu conexion a internet",
                                            timeInSecForIosWeb: 2,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP,
                                            webShowClose: true,
                                          );
                                        } else {
                                          setState(() {
                                            prefs.statusRoute = "INRT";
                                          });
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        prefs.statusRoute = "INRT";
                                      });
                                    }
                                  },
                                  decoration: Decorations.greenBorder5,
                                  style: TextStyles.white17_6,
                                  label: "Iniciar ruta")
                      : ButtonJunghanns(
                          fun: () {},
                          decoration: Decorations.whiteBorder5Red,
                          style: TextStyles.red17_6,
                          label: "ESTÁS A ${dif.ceil()} mtrs DEL CLIENTE !!")),
          const SizedBox(
            height: 20,
          ),
          history()
        ],
      ),
    );
  }

  Widget observation(String titleO, String textO) {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              side: titleO == "Observaciones de servicio"
                  ? BorderSide.none
                  : titleO == "Descripción de servicio"
                      ? const BorderSide(
                          color: ColorsJunghanns.greenJ, width: 1)
                      : const BorderSide(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(5.0)),
          child: Container(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 10, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        titleO,
                        style: titleO == "Observaciones de servicio"
                            ? TextStyles.blueJ20Bold
                            : titleO == "Descripción de servicio"
                                ? TextStyles.greenJ20Bold
                                : TextStyles.orangeJ20Bold,
                      )),
                      titleO == "Observaciones de servicio"
                          ? Image.asset(
                              "assets/icons/observationIcon.png",
                              width: 50,
                            )
                          : Icon(
                              titleO == "Descripción de servicio"
                                  ? FontAwesomeIcons.exclamationCircle
                                  : FontAwesomeIcons.exclamationTriangle,
                              color: titleO == "Descripción de servicio"
                                  ? ColorsJunghanns.greenJ
                                  : ColorsJunghanns.orange,
                              size: 28,
                            ),
                    ],
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 4, right: 4, bottom: 5, top: 8),
                      child: Text(textO,
                          textAlign: TextAlign.justify,
                          style: TextStyles.grey17_4)),
                  /*Container(
                    width: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      "assets/icons/editIcon.png",
                      width: 25,
                    ),
                  )*/
                ],
              )),
        ));
  }

  Widget photoCard() {
    return Container(
        width: double.infinity,
        height: size.width * .50,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            image: widget.customerCurrent.img == "" ||
                    widget.customerCurrent.img ==
                        "https://sandbox.junghanns.app/img/clientes/address/SANDBOX/"
                ? const DecorationImage(
                    image: AssetImage("assets/images/withoutPicture.png"),
                    fit: BoxFit.cover)
                : DecorationImage(
                    image: NetworkImage(widget.customerCurrent.img),
                    fit: BoxFit.cover)),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            pickedImageFile != null
                ? Container(
                    width: double.infinity,
                    height: size.width * .50,
                    child: Card(
                      child: Image.file(
                        pickedImageFile,
                        fit: BoxFit.cover,
                      ),
                    ))
                : Container(),
            GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, top: 10, bottom: 10),
                  margin: const EdgeInsets.all(10),
                  decoration: Decorations.greenBorder5,
                  child: const Text(
                    "Ubicación Actual",
                    style: TextStyles.white17_5,
                  ),
                ),
                onTap: () => funCurrentLocation())
          ],
        ));
  }

  Widget history() {
    return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            photoCard(),
            //
            const SizedBox(
              height: 20,
            ),
            const Text(
              "\t\t\t\tHistorial de visitas",
              style: TextStyles.blue25_7,
            ),
            const SizedBox(
              height: 20,
            ),
            widget.customerCurrent.history.isEmpty
                ? Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    alignment: Alignment.center,
                    child: const Text(
                      "Sin historial",
                      style: TextStyles.grey17_4,
                    ))
                : Column(
                    children: widget.customerCurrent.history
                        .map((e) => Column(
                              children: [
                                SalesCard(saleCurrent: e),
                                Row(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: (size.width * .07) + 15),
                                    color: ColorsJunghanns.grey,
                                    width: .5,
                                    height: 15,
                                  )
                                ])
                              ],
                            ))
                        .toList(),
                  )
          ],
        ));
  }
}
