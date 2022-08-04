// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/pages/shop/shopping_cart.dart';
import 'package:junghanns/pages/shop/stops.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/sales.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth.dart';

class DetailsCustomer extends StatefulWidget {
  CustomerModel customerCurrent;
  DetailsCustomer({Key? key, required this.customerCurrent}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DetailsCustomerState();
}

class _DetailsCustomerState extends State<DetailsCustomer> {
  late ProviderJunghanns provider;
  late dynamic pickedImageFile;
  late Size size;
  late bool isRange;
  late bool isLoading;

  late List<ConfigModel> configList;

  @override
  void initState() {
    super.initState();
    isRange = false;
    pickedImageFile = null;
    configList = [];
    isLoading = true;
    getConfigR();
  }

  getConfigR() async {
    await getConfig().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        log("Config yes");
        answer.body
            .map((e) => configList.add(ConfigModel.fromService(e)))
            .toList();
        getDataDetails();
      }
    });
  }

  getAuth() async {
    await getAuthorization(widget.customerCurrent.idClient, prefs.idRouteD)
        .then((answer) {
      if (answer.error) {
        /*Fluttertoast.showToast(
          msg: "Sin autorizaciones",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );*/
        log("Sin Autorizaciones");
      } else {
        log("Auth yes");
      }
      setCurrentLocation();
    });
  }

  getDataDetails() async {
    await getDetailsCustomer(widget.customerCurrent.id).then((answer) {
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
          widget.customerCurrent =
              CustomerModel.fromService(answer.body, widget.customerCurrent.id);
        });
        getAuth();
      }
    });
  }

  navigatorShopping(bool isPR) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ShoppingCart(
                  customerCurrent: widget.customerCurrent,
                  isPR: isPR,
                )));
  }

  navigatorStops() async {
    /*LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      if (Geolocator.distanceBetween(
                  _currentLocation.latitude,
                  _currentLocation.longitude,
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng) <
              int.parse(configList.last.valor) ||
          provider.connectionStatus == 4) {
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => Stops(
                      customerCurrent: widget.customerCurrent,
                    )));
      } else {
        Fluttertoast.showToast(
          msg: "Lejos del domicilio",
          timeInSecForIosWeb: 16,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    } else {
      log("permission $permission");
    }*/
    _onLoading();
    bool isValid = await funCheckDistance();
    if (isValid) {
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => Stops(
                  customerCurrent: widget.customerCurrent,
                  distance: int.parse(configList.last.valor))));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Lejos del domicilio",
        timeInSecForIosWeb: 16,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  setCurrentLocation() async {
    bool isValid = await funCheckDistance();
    setState(() {
      isRange = isValid;
      isLoading = false;
    });
  }

  funCurrentLocation() {
    if (widget.customerCurrent.lat != 0 && widget.customerCurrent.lng != 0) {
      log("Con ubicación");
      var urlAux = Uri(
          scheme: 'https',
          host: 'www.google.com',
          path: '/maps/search/',
          queryParameters: {
            'api': '1',
            'query':
                '${widget.customerCurrent.lat},${widget.customerCurrent.lng}'
          });
      log(urlAux.toString());
      launchUrl(urlAux);
      //
    } else {
      log("Sin Ubicación");
    }
  }

  void _pickImage(int type) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.getImage(
          source: type == 1 ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80);
      setState(() {
        pickedImageFile = File(pickedImage!.path);
      });

      if (pickedImageFile != null) {
        await updateAvatar(
            pickedImageFile,
            widget.customerCurrent.id.toString(),
            widget.customerCurrent.nameRoute);
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

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.blueJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.blueJ,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menuWhite.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      backgroundColor: ColorsJunghanns.lightBlue,
      body: isLoading ? loading() : refreshScroll(),
    );
  }

  Widget header() {
    return Container(
        color: ColorsJunghanns.blue,
        padding: EdgeInsets.only(
            right: 15, left: 23, top: 10, bottom: size.height * .03),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
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
                  Text(
                    "${widget.customerCurrent.idClient}",
                    style: TextStyles.green22_4,
                  ),
                  Text(
                    widget.customerCurrent.name,
                    style: TextStyles.white20SemiBoldIt,
                  ),
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
          Container(
            padding: const EdgeInsets.only(top: 10, right: 25),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                const Icon(
                  Icons.location_on,
                  color: ColorsJunghanns.green,
                ),
                Expanded(
                    child: AutoSizeText(
                  widget.customerCurrent.address,
                  style: TextStyles.white15It,
                ))
              ],
            ),
          )
        ]));
  }

  Widget refreshScroll() {
    return RefreshIndicator(
        child: SingleChildScrollView(
          child: Column(
            children: [
              header(),
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
              balances(),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        onRefresh: () async {
          log("Refresh");
          bool isvalid = await funCheckDistance();
          setState(() {
            isRange = isvalid;
          });
        });
  }

  Widget photoCard() {
    return Container(
        width: double.infinity,
        height: size.width * .50,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            image: widget.customerCurrent.img == ""
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
                                text: getNameRouteRich(
                                    widget.customerCurrent.nameRoute)[0],
                                style: TextStyles.white17_5),
                            TextSpan(
                                text:
                                    " ${getNameRouteRich(widget.customerCurrent.nameRoute)[1]}",
                                style: TextStyles.white27_7)
                          ])))),
                ],
              )),
          const SizedBox(
            height: 20,
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
          const SizedBox(
            height: 20,
          ),
          //
          observation(),
          //
          const SizedBox(
            height: 20,
          ),
          Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: itemBalance("liquitIcon.png", "Precio Liquido",
                          widget.customerCurrent.priceLiquid)),
                  Expanded(
                      child: itemBalance("cashIcon.png", "Monedero",
                          widget.customerCurrent.purse)),
                  Expanded(
                      child: itemBalance("creditIcon.png", "Por cobrar",
                          widget.customerCurrent.byCollect))
                ],
              )),
          const SizedBox(
            height: 20,
          ),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: isRange
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: ButtonJunghanns(
                                decoration: Decorations.greenBorder5,
                                style: TextStyles.white17_5,
                                fun: funCheckDistanceSale,
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
                                fun: navigatorStops,
                                isIcon: true,
                                icon: Container(
                                  width: 0,
                                  height: 30,
                                ),
                                label: "Parada"))
                      ],
                    )
                  : ButtonJunghanns(
                      fun: () {},
                      decoration: Decorations.whiteBorder5Red,
                      style: TextStyles.red17_6,
                      label: "ESTÁS MUY LEJOS DEL CLIENTE !!")),
          const SizedBox(
            height: 20,
          ),
          history()
        ],
      ),
    );
  }

  funCheckDistanceSale() async {
    _onLoading();
    bool isValid = await funCheckDistance();
    if (isValid) {
      Navigator.pop(context);
      showSelectPR();
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Lejos del domicilio",
        timeInSecForIosWeb: 16,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
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
                        fun: () => navigatorShopping(true),
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
                          fun: () => navigatorShopping(false),
                          decoration: Decorations.whiteSblackCard,
                          style: TextStyles.blue16_4,
                          label: "Recargas"))
                ],
              ),
            ),
          );
        });
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

  Widget observation() {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Container(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 10, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                          child: Text(
                        "Observaciones",
                        style: TextStyles.blue23_7,
                      )),
                      Image.asset(
                        "assets/icons/observationIcon.png",
                        width: 50,
                      ),
                    ],
                  ),
                  Text(widget.customerCurrent.observation),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      "assets/icons/editIcon.png",
                      width: 25,
                    ),
                  )
                ],
              )),
        ));
  }

  Widget itemBalance(String image, String label, double count) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(
          height: 10,
        ),
        Image.asset(
          "assets/icons/$image",
          width: size.width * .16,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          checkDouble(count.toString()),
          style: TextStyles.blue27_7,
        ),
        Text(label, style: TextStyles.grey14_7),
        const SizedBox(
          height: 10,
        ),
      ]),
    );
  }

  Future<bool> funCheckDistance() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      if (Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              widget.customerCurrent.lat,
              widget.customerCurrent.lng) <
          int.parse(configList.last.valor)) {
        return true;
      } else {
        return false;
      }
    } else {
      print({"permission": permission.toString()});
      return false;
    }
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

  void _onLoading() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
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
      },
    );
  }
}
