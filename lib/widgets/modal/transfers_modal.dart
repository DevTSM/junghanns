import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/pages/drawer/delivery_of_products.dart';
import 'package:junghanns/styles/color.dart';
import '../../pages/drawer/transfers.dart';
import '../../util/navigator.dart';
import '../button/button_attencion.dart';

void showTransferModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(18),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(
                  FontAwesomeIcons.arrowsSpin,
                  size: 30.0,
                  color: ColorsJunghanns.blueJ,
                ),
                const SizedBox(height: 15),
                Text(
                  "TRASFERENCIA PENDIENTE",
                  style: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(fontSize: 19, color: JunnyColor.black, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Tienes una trasferencia pendiente',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonAttention(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(builder: (context) => const Transfers()),
                          (route) => false,
                    ),
                    // Navigator.pop(context),
                    color: ColorsJunghanns.blueJ,
                    label: "IR A TRANSFERENCIA",
                    width: double.infinity,
                    colorDotted: ColorsJunghanns.white,
                    radius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
