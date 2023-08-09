import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:path_provider/path_provider.dart';
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
  late bool isLoading;

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
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.whiteJ,
    systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: ColorsJunghanns.whiteJ,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark),
        elevation: 0,
    leading:IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back_ios,color: ColorsJunghanns.blue,))
      ),
    body:RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await getQR();
          setState(() {
            list = prefs.qr != "" ? List.from(jsonDecode(prefs.qr)) : [];
            if (list.length == 1) {
              nameCurrent = list.first;
            } else {
              nameCurrent = {"name": "Selecciona una opción"};
              list.add(nameCurrent);
            }
            isLoading = false;
          });
          // setState(() {
          //   nameCurrent={};
          //   prefs.qr="";
          //   list=[];
          // });
        },
        child: Stack(children: [
          SingleChildScrollView(
            child: body(),
          ),
          Visibility(
            visible: isLoading,
            child: const LoadingJunghanns(),
          )
        ])));
  }

  Widget body({bool isShared = false}) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
        decoration: list.where((element) => element["url"] != null).isEmpty
            ? const BoxDecoration(color: ColorsJunghanns.lightBlue)
            : const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/images/junghannsWater.png",
                    ),
                    fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
                visible: isShared,
                child: Image.asset("assets/images/junghannsLogo.png")),
            //Intrucciones
            Visibility(
                visible: (nameCurrent["url"] == null ||
                    prefs.qr == "" ||
                    prefs.qr == "[]"),
                child: Container(
                  padding:const EdgeInsets.only(top: 10, bottom: 80),
                  child: Text(
                    prefs.qr == ""
                        ? "Ups!! no fue posible obtener la información, por favor intenta sincronizar"
                        : list
                                .where((element) => element["url"] != null)
                                .isEmpty
                            ? "EL Roll de reparto no ha sido registrado"
                            : "Por favor selecciona una opcion para poder generar el QR",
                    style: prefs.qr == "[]"
                        ? TextStyles.redJ20Bold
                        : TextStyles.blue19_4,
                    textAlign: TextAlign.center,
                  ),
                )),
            //Select
            prefs.qr != "" && prefs.qr != "[]" && !isShared
                ? Container(
                    decoration:
                        list.where((element) => element["url"] != null).length >
                                1
                            ? Decorations.whiteSblackCard
                            : const BoxDecoration(),
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    alignment: Alignment.center,
                    child: list
                                .where((element) => element["url"] != null)
                                .length >
                            1
                        ? DropdownButton<Map<String, dynamic>>(
                            isExpanded: true,
                            dropdownColor: ColorsJunghanns.lighGrey,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            underline: Container(),
                            value: nameCurrent,
                            icon: const Icon(Icons.arrow_drop_down_sharp),
                            elevation: 5,
                            onChanged: (Map<String, dynamic>? value) {
                              if (value!["url"] != null) {
                                setState(() {
                                  nameCurrent = value;
                                  list.removeWhere(
                                      (element) => element["url"] == null);
                                });
                              }
                            },
                            items: list
                                .map<DropdownMenuItem<Map<String, dynamic>>>(
                                    (Map<String, dynamic> value) {
                              return DropdownMenuItem<Map<String, dynamic>>(
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
                            padding: const EdgeInsets.only(bottom: 10, top: 10),
                            child: Text(
                              nameCurrent["name"],
                              textAlign: TextAlign.center,
                              style: TextStyles.blue16_4,
                            )))
                : Container(),
            SizedBox(
              child: list.where((element) => element["url"] != null).isEmpty
                  ? Container(
                      padding: list
                              .where((element) => element["url"] != null)
                              .isEmpty
                          ? const EdgeInsets.only(left: 0, right: 0)
                          : EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .15,
                              right: MediaQuery.of(context).size.width * .15),
                      child: Image.asset(
                        "assets/images/jh_wpa_ele-07.png",
                        fit: BoxFit.contain,
                      ))
                  : qrWidget(),
            ),
            !isShared
                ? shared()
                : Container(
                    decoration: Decorations.whiteSblackCard,
                    margin: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: MediaQuery.of(context).size.height * .2,
                        top: MediaQuery.of(context).size.height * .1),
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 15),
                    alignment: Alignment.center,
                    child: Text(
                      nameCurrent["name"],
                      style: TextStyles.blue15SemiBold,
                      textAlign: TextAlign.center,
                    ))
          ],
        ));
  }

  Widget qrWidget() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * .2),
      width: MediaQuery.of(context).size.width -
          (list.where((element) => element["url"] != null).isEmpty ? 0 : 100),
      height: MediaQuery.of(context).size.width - 100,
      child: nameCurrent["url"] != null
          ? Container(
              alignment: Alignment.center,
              decoration: Decorations.white2Card,
              child: QrImageView(
                size: MediaQuery.of(context).size.width - 100,
                data: nameCurrent["url"],
                gapless: true,
                version: QrVersions.auto,
                padding: const EdgeInsets.all(15),
                //backgroundColor: ColorsJunghanns.white,
                foregroundColor: ColorsJunghanns.blue,
              ))
          : Container(
              padding: list.where((element) => element["url"] != null).isEmpty
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
    );
  }

  Widget noRoll() {
    return Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * .2),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
                decoration: Decorations.whiteSblackCard,
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .1,
                    right: MediaQuery.of(context).size.width * .1,
                    top: MediaQuery.of(context).size.width * .07),
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 23, bottom: 15),
                child: Text(
                  "Reportate con tu supervisor para asignar un Rol",
                  style: TextStyles.blueJ15SemiBold,
                  textAlign: TextAlign.center,
                )),
            Image.asset(
              "assets/images/jh_wpa_ele-06.png",
              height: 50,
              width: MediaQuery.of(context).size.width * .15,
            )
          ],
        ));
  }

  Widget shared() {
    return nameCurrent['url'] != null
        ? Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .1,
                bottom: MediaQuery.of(context).size.height * .2),
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * .1,
                right: MediaQuery.of(context).size.width * .1,
                bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      screenshotController
                          .captureFromWidget(
                              InheritedTheme.captureAll(context,
                                  Material(child: body(isShared: true))),
                              delay: const Duration(seconds: 1))
                          .then((capturedImage) async {
                        final tempDir = await getTemporaryDirectory();
                        File file =
                            await File('${tempDir.path}/image.png').create();

                        file.writeAsBytesSync(capturedImage);
                        final result =
                            await ImageGallerySaver.saveFile(file.path);
                        setState(() {
                          isLoading = false;
                        });
                        if (result['isSuccess']) {
                          log('Imagen guardada en la galería');
                        } else {
                          log('Error al guardar la imagen: ${result['errorMessage']}');
                        }
                        await Share.shareFiles(
                          [file.path],
                        );
                      });
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/icons/shared.png",
                          width: 40,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Compartir",
                          style: TextStyles.grey15Itw,
                        )
                      ],
                    )),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      screenshotController
                          .captureFromWidget(
                              InheritedTheme.captureAll(context,
                                  Material(child: body(isShared: true))),
                              delay: const Duration(seconds: 1))
                          .then((capturedImage) async {
                        final tempDir = await getTemporaryDirectory();
                        File file = await File(
                                '${tempDir.path}/${nameCurrent["name"]}.png')
                            .create();
                        file.writeAsBytesSync(capturedImage);
                        var result =
                            await ImageGallerySaver.saveFile(file.path);
                        setState(() {
                          isLoading = false;
                        });
                        if (result['isSuccess']) {
                          Fluttertoast.showToast(
                            msg: "Imagen guardada en la galería",
                            timeInSecForIosWeb: 2,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            webShowClose: true,
                          );
                        }
                      });
                    },
                    child: Column(children: [
                      Image.asset(
                        "assets/icons/save.png",
                        width: 40,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Guardar",
                        style: TextStyles.grey15Itw,
                      )
                    ])),
              ],
            ))
        : prefs.qr == "[]"
            ? noRoll()
            : Container();
  }
}
