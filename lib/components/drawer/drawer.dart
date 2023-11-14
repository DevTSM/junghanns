import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/components/modal/yes_not.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/pages/debug/debug.dart';
import 'package:junghanns/pages/drawer/devoluciones.dart';
import 'package:junghanns/pages/home/atendidos.dart';
import 'package:junghanns/pages/home/autorizaciones.dart';
import 'package:junghanns/pages/home/call.dart';
import 'package:junghanns/pages/home/qr.dart';
import 'package:junghanns/pages/transfer/transfer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:location/location.dart';

updateStatus(ProviderJunghanns provider, String status) async {
  try {
    LocationData currentLocation = LocationData.fromMap({});
    Location locationInstance = Location();
    PermissionStatus permission = await locationInstance.hasPermission();
    if (permission == PermissionStatus.granted) {
      provider.isStatusloading = true;
      locationInstance.changeSettings(accuracy: LocationAccuracy.high);
      if (await locationInstance.serviceEnabled()) {
        currentLocation = await locationInstance
            .getLocation()
            .timeout(const Duration(seconds: 15));
        StopRuta stop = StopRuta(
            id: 1,
            update: 0,
            lat: currentLocation.latitude!,
            lng: currentLocation.longitude!,
            status: status == "inicio_comida" ? "INCM" : "FNRT");
        int id = await handler.insertStopRuta(stop);
        await setInitRoute(
                currentLocation.latitude!, currentLocation.longitude!,
                status: status)
            .then((answer) {
          provider.isStatusloading = false;
          if (!answer.error) {
            handler.updateStopRuta(1, id);
          }
        });
        prefs.statusRoute = status == "inicio_comida" ? "INCM" : "FNRT";
        Fluttertoast.showToast(
          msg: status == "inicio_comida"
              ? "¡Buen provecho!"
              : "Te esperamos mañana",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        provider.isStatusloading = false;
        Fluttertoast.showToast(
            msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
            backgroundColor: ColorsJunghanns.red);
      }
    } else {
      print({"permission": permission.toString()});
    }
  } catch (e) {
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

drawer(ProviderJunghanns provider, BuildContext context,
    Function setIndexCurrent, bool isFinRuta) {
  item(Function navigator, String icon, String title, {Widget? image}) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Scaffold.of(context).closeDrawer();
          navigator();
        },
        child: Column(
          children: [
            Row(
              children: [
                image ??
                  Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                    color: JunnyColor.blueC2,
                  ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyles.blue16_4,
                )
              ],
            ),
            const Divider(
              color: ColorsJunghanns.lighGrey,
              height: 18,
              thickness: 2,
            )
          ]
        )
      )
    );
  }

  return Drawer(
    child: Container(
      padding:const EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 50),
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/junghannsWater.png")
        )
      ),
      child: Builder(
        builder: (context) => Column(
          children: [
            Image.asset("assets/images/junghannsLogo.png"),
            const SizedBox(height: 50),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const Atendidos()
                        )
                      ),
                      "assets/icons/iconCheck.png",
                      "Atendidos"
                    ),
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const Autorizaciones()
                        )
                      ),
                      "assets/icons/auth.png",
                      "Autorizaciones"
                    ),
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const Call()
                        )
                      ),
                      "assets/icons/menuOp5B.png",
                      "Cliente llama"
                    ),
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const Debug()
                        )
                      ),
                      "assets/icons/observationIcon.png",
                      "Debug"
                    ),
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const Devoluciones()
                        )
                      ),
                      "assets/icons/observationIcon.png",
                      "Devoluciones",
                      image: const Icon(
                        Icons.change_circle,
                        size: 24,
                        color: ColorsJunghanns.blue,
                      ),
                    ),
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const QRSeller()
                        )
                      ),
                      "",
                      "QR",
                      image: const Icon(
                        Icons.qr_code_2,
                        size: 24,
                        color: ColorsJunghanns.blue,
                      ),
                    ),
                    item(
                      () => Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) =>
                          const Transfer()
                        )
                      ),
                      "assets/icons/menuOp4B.png",
                      "Transferencias"
                    ),
                    item(
                      () async {
                        provider.asyncProcess=true;
                        provider.labelAsync="Verificando la integridad de la base de datos...";
                        provider.totalAsync=2;
                        provider.currentAsync=1;
                        bool verified = await handler.checkValidate();
                        Timer(const Duration(seconds: 2), () {
                          provider.currentAsync=2;
                          if (verified) {
                            provider.labelAsync="Base de datos integra";
                          } else {
                            provider.labelAsync="La base de datos está corrupta";
                            Fluttertoast.showToast(
                              msg: "La base de datos está corrupta",
                              timeInSecForIosWeb: 2,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              webShowClose: true,
                              backgroundColor: ColorsJunghanns.red
                            );
                          }
                        });
                        Timer(const Duration(seconds: 4), () {
                          provider.asyncProcess=false;
                        });
                      },
                      "",
                      "Verificar BD",
                      image: const Icon(
                        Icons.data_object,
                        size: 24,
                        color: ColorsJunghanns.blue,
                      ),
                    ),
                  ],
                ),
              )
            ),
            Visibility(
              visible: prefs.statusRoute != "FNRT",
              child: Row(
                children: [
                  Visibility(
                    visible: prefs.statusRoute == "INRT",
                    child: Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Scaffold.of(context).closeDrawer();
                          showYesNot(
                            context,
                            () => updateStatus(provider, "inicio_comida"),
                            "inicio_comida",
                            false
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: Decorations.greenBorder12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Icon(
                                Icons.fastfood_outlined,
                                color: ColorsJunghanns.white,
                              ),
                              AutoSizeText(
                                "Comida",
                                style: TextStyles.white14SemiBold,
                              ),
                            ],
                          )
                        )
                      )
                    )
                  ),
                  const SizedBox(width: 20),
                  Visibility(
                    visible: isFinRuta && prefs.statusRoute != "",
                    child: Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Scaffold.of(context).closeDrawer();
                          await showYesNot(context,
                            () => updateStatus(provider, "fin"),
                            "fin",
                            false
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: Decorations.blueBorder12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Icon(
                                Icons.close,
                                color:ColorsJunghanns.white,
                              ),
                              AutoSizeText(
                                prefs.statusRoute == "FNCM"
                                  ? "Finalizar ruta"
                                  : "Fin",
                                style: TextStyles.white14SemiBold,
                              ),
                            ],
                          )
                        )
                      )
                    )
                  ),
                ],
              )
            ),
          ],
        )
      )
    )
  );
}
