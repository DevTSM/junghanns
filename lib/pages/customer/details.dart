// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/pages/shop/shopping_cart.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/sales.dart';

class DetailsCustomer extends StatefulWidget {
  CustomerModel customerCurrent;
  DetailsCustomer({Key? key, required this.customerCurrent}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DetailsCustomerState();
}

class _DetailsCustomerState extends State<DetailsCustomer> {
  late dynamic pickedImageFile;
  late Size size;
  late bool isRange;
  @override
  void initState() {
    super.initState();
    isRange = false;
    pickedImageFile = null;
    setCurrentLocation();
    getDataDetails();
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
      }
    });
  }

  navigatorShopping() {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ShoppingCart(customerCurrent:widget.customerCurrent)));
  }

  setCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position _currentLocation = await Geolocator.getCurrentPosition();
      if (Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              widget.customerCurrent.lat,
              widget.customerCurrent.lng) <
          30000000) {
        setState(() {
          isRange = true;
        });
      }
    } else {
      print({"permission": permission.toString()});
    }
  }

  void _pickImage(int type) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.getImage(
          source: type == 1 ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 80);
      pickedImageFile = File(pickedImage!.path);
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            header(),
            balances(),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
        color: ColorsJunghanns.blue,
        padding: EdgeInsets.only(
            right: 15, left: 23, top: 10, bottom: size.height * .08),
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
                    style: TextStyles.green17_4,
                  ),
                  Text(
                    widget.customerCurrent.name,
                    style: TextStyles.white17_6,
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
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              const Icon(
                Icons.location_on,
                color: ColorsJunghanns.green,
              ),
              Text(
                widget.customerCurrent.address,
                style: TextStyles.white12_4,
              )
            ],
          )
        ]));
  }

  Widget balances() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .13),
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(right: 15, left: 15),
              width: double.infinity,
              height: size.width * .50,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      image: AssetImage("assets/images/withoutPicture.png"),
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
                  Container(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 10),
                    margin: const EdgeInsets.all(10),
                    decoration: Decorations.greenBorder5,
                    child: const Text(
                      "Ubicación Actual",
                      style: TextStyles.white17_5,
                    ),
                  )
                ],
              )),
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
                            const Text(
                              "Lunes, 24 Junio",
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
                              text: const TextSpan(children: [
                            TextSpan(text: "Ruta", style: TextStyles.white17_5),
                            TextSpan(text: "   10", style: TextStyles.white27_7)
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
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: isRange
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            child: ButtonJunghanns(
                                decoration: Decorations.greenBorder5,
                                style: TextStyles.white17_5,
                                fun: navigatorShopping,
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
                                fun: navigatorShopping,
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

  Widget history() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 30,
          color: ColorsJunghanns.white,
        ),
        Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                observation(),
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
            ))
      ],
    );
  }

  Widget observation() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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
    );
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
}
