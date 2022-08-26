import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

showConfirmLogOut(BuildContext context,Size size) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: size.width * .75,
              decoration: Decorations.whiteS1Card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      child: const Text("Cerrar sesión")),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          flex: 2,
                          child: ButtonJunghannsLabel(
                              width: double.infinity,
                              fun: () => () {
                                    Navigator.pop(context);
                                    log("LOG OUT");
                                    //-------------------------*** LOG OUT
                                    prefs.isLogged = false;
                                    prefs.idUserD = 0;
                                    prefs.idProfileD = 0;
                                    prefs.nameUserD = "";
                                    prefs.nameD = "";
                                    prefs.idRouteD = 0;
                                    prefs.nameRouteD = "";
                                    prefs.dayWorkD = "";
                                    prefs.dayWorkTextD = "";
                                    prefs.codeD = "";
                                    //--------------------------*********
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/', (route) => false);
                                  },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Si")),
                      const Expanded(
                          child: SizedBox(
                        width: 15,
                      )),
                      Expanded(
                          flex: 2,
                          child: ButtonJunghannsLabel(
                              width: double.infinity,
                              fun: () => () => () {
                                    Navigator.pop(context);
                                  },
                              decoration: Decorations.redCard,
                              style: TextStyles.white18SemiBoldIt,
                              label: "No")),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }