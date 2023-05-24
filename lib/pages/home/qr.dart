import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QRSeller extends StatefulWidget {
  const QRSeller({super.key});

  @override
  State<StatefulWidget> createState() => _QRSellerState();
}

class _QRSellerState extends State<QRSeller> {
  late ScreenshotController screenshotController;
  late Map<String, dynamic> nameCurrent;
  late List<Map<String, dynamic>> list;

  @override
  void initState() {
    super.initState();
    screenshotController = ScreenshotController();
    list = prefs.qr != "" ? List.from(jsonDecode(prefs.qr)) : [];
    if (list.length == 1) {
      nameCurrent = list.first;
    } else {
      nameCurrent = {"name": "Selecciona una opción"};
      list.add(nameCurrent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
        controller: screenshotController,
        child: Container(
            decoration: list.where((element) => element["url"] != null).isEmpty
                ? const BoxDecoration(color: ColorsJunghanns.lightBlue)
                : const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          "assets/images/junghannsWater.png",
                        ),
                        fit: BoxFit.cover)),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: double.infinity,
                ),
                //Intrucciones
                Visibility(
                    visible: nameCurrent["url"] == null || prefs.qr == "",
                    child: Container(
                      padding: list
                              .where((element) => element["url"] != null)
                              .isEmpty
                          ? const EdgeInsets.all(0)
                          : const EdgeInsets.only(top: 40, bottom: 30),
                      child: Text(
                        prefs.qr == ""
                            ? "Ups!! no fue posible obtener la información, por favor intenta sincronizar"
                            : list
                                    .where((element) => element["url"] != null)
                                    .isEmpty
                                ? ""
                                : "Por favor selecciona una opcion para poder generar el QR",
                        style: TextStyles.blue19_4,
                        textAlign: TextAlign.center,
                      ),
                    )),
                //Select
                Visibility(
                    visible: prefs.qr != "",
                    child: Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                              decoration: list
                                          .where((element) =>
                                              element["url"] != null)
                                          .length >
                                      1?Decorations.whiteSblackCard:const BoxDecoration(),
                              margin:
                                  const EdgeInsets.only(left: 15, right: 15),
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.center,
                              child: list
                                          .where((element) =>
                                              element["url"] != null)
                                          .length >
                                      1
                                  ? DropdownButton<Map<String, dynamic>>(
                                      isExpanded: true,
                                      dropdownColor: ColorsJunghanns.lighGrey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      underline: Container(),
                                      value: nameCurrent,
                                      icon: const Icon(
                                          Icons.arrow_drop_down_sharp),
                                      elevation: 5,
                                      onChanged: (Map<String, dynamic>? value) {
                                        if (value!["url"] != null) {
                                          setState(() {
                                            nameCurrent = value;
                                            list.removeWhere((element) =>
                                                element["url"] == null);
                                          });
                                        }
                                      },
                                      items: list.map<
                                              DropdownMenuItem<
                                                  Map<String, dynamic>>>(
                                          (Map<String, dynamic> value) {
                                        return DropdownMenuItem<
                                            Map<String, dynamic>>(
                                          value: value,
                                          child: Text(
                                            value["name"],
                                            style: TextStyles.blue15SemiBold,
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(
                                          bottom: 10, top: 10),
                                      child: Text(
                                        list
                                                .where((element) =>
                                                    element["url"] != null)
                                                .isEmpty
                                            ? "EL Roll de reparto no ha sido registrado"
                                            : nameCurrent["name"],
                                        textAlign: TextAlign.center,
                                        style: list
                                                .where((element) =>
                                                    element["url"] != null)
                                                .isEmpty
                                            ? TextStyles.redJ20Bold
                                            : TextStyles.blue16_4,
                                      )))
                        ]))),

                list.where((element) => element["url"] != null).isEmpty
                    ? const SizedBox()
                    : qrWidget(),
                list.where((element) => element["url"] != null).isEmpty
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              padding: list
                                      .where(
                                          (element) => element["url"] != null)
                                      .isEmpty
                                  ? const EdgeInsets.only(left: 0, right: 0)
                                  : EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          .15,
                                      right: MediaQuery.of(context).size.width *
                                          .15),
                              child: Image.asset(
                                "assets/images/jh_wpa_ele-07.png",
                                fit: BoxFit.contain,
                              )),
                          Container(
                              decoration: Decorations.whiteSblackCard,
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * .1,
                                  right: MediaQuery.of(context).size.width * .1,
                                  top: MediaQuery.of(context).size.width - 10),
                              padding: const EdgeInsets.only(
                                  left: 18, right: 18, top: 23, bottom: 15),
                              child: Text(
                                "Reportate con tu supervisor para asignar un Rol",
                                style: TextStyles.blueJ15SemiBold,
                                textAlign: TextAlign.center,
                              )),
                          Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.width - 100),
                              child: Image.asset(
                                "assets/images/jh_wpa_ele-06.png",
                                width: MediaQuery.of(context).size.width * .15,
                              ))
                        ],
                      )
                    : const SizedBox(),
                nameCurrent['url'] != null
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1,
                            right: MediaQuery.of(context).size.width * .1,
                            bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                screenshotController
                                    .captureFromWidget(
                                        InheritedTheme.captureAll(
                                            context,
                                            Material(
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    decoration:
                                                        const BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                                    image:
                                                                        AssetImage(
                                                                      "assets/images/junghannsWater.png",
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover)),
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Image.asset(
                                                          "assets/images/junghannsLogo.png",
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    nameCurrent[
                                                                        "name"],
                                                                    style: TextStyles
                                                                        .blue15SemiBold))),
                                                        qrWidget()
                                                      ],
                                                    )))),
                                        delay: Duration(seconds: 1))
                                    .then((capturedImage) async {
                                  final tempDir = await getTemporaryDirectory();
                                  File file =
                                      await File('${tempDir.path}/image.png')
                                          .create();
                                  file.writeAsBytesSync(capturedImage);
                                  await Share.shareFiles(
                                    [file.path],
                                  );
                                });
                              },
                              child:Column(
                                children: [
                                  Image.asset(
                                "assets/icons/shared.png",
                                width: 40,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text("Compartir",style: TextStyles.grey15Itw,)
                                ],
                              )
                            ),
                            GestureDetector(
                              onTap: () {
                                screenshotController
                                    .captureFromWidget(
                                        InheritedTheme.captureAll(
                                            context,
                                            Material(
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            30),
                                                    decoration:
                                                        const BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                                    image:
                                                                        AssetImage(
                                                                      "assets/images/junghannsWater.png",
                                                                    ),
                                                                    fit: BoxFit
                                                                        .cover)),
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Image.asset(
                                                          "assets/images/junghannsLogo.png",
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                    nameCurrent[
                                                                        "name"],
                                                                    style: TextStyles
                                                                        .blue15SemiBold))),
                                                        qrWidget()
                                                      ],
                                                    )))),
                                        delay: Duration(seconds: 1))
                                    .then((capturedImage) async {
                                  final tempDir = await getTemporaryDirectory();
                                  File file = await File(
                                          '${tempDir.path}/${nameCurrent["name"]}.png')
                                      .create();
                                  file.writeAsBytesSync(capturedImage);
                                  Fluttertoast.showToast(
                                    msg: "Guardado en \n $tempDir",
                                    timeInSecForIosWeb: 2,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    webShowClose: true,
                                  );
                                });
                              },
                              child: Column(
                                children:[
                                Image.asset(
                                "assets/icons/save.png",
                                width: 40,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text("Guardar",style: TextStyles.grey15Itw,)])
                            ),
                          ],
                        ))
                    : Container()
              ],
            )));
  }

  Widget qrWidget() {
    return Expanded(
        flex: 2,
        child: SizedBox(
          width: MediaQuery.of(context).size.width -
              (list.where((element) => element["url"] != null).isEmpty
                  ? 0
                  : 100),
          height: MediaQuery.of(context).size.width - 100,
          child: nameCurrent["url"] != null
              ? QrImage(
                  size: MediaQuery.of(context).size.width - 100,
                  data: nameCurrent["url"],
                  gapless: true,
                  version: QrVersions.auto,
                  padding: const EdgeInsets.all(10),
                  backgroundColor: Colors.transparent,
                  foregroundColor: ColorsJunghanns.blue,
                )
              : Container(
                  padding:
                      list.where((element) => element["url"] != null).isEmpty
                          ? const EdgeInsets.only(left: 0, right: 0)
                          : EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .15,
                              right: MediaQuery.of(context).size.width * .15),
                  child: Image.asset(
                    prefs.qr == ""
                        ? "assets/images/async.png"
                        : "assets/images/jh_wpa_ele-02.png",
                    fit: BoxFit.contain,
                  )),
        ));
  }

  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }
}
