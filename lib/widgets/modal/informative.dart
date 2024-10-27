import 'package:flutter/material.dart';

import '../../styles/color.dart';
import '../button/button_attencion.dart';

class CustomModal {
  static void show({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
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
                Icon(icon, size: 42.0, color: iconColor),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(fontSize: 19, color: JunnyColor.black, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonAttention(
                    onTap: () =>
                    //TODO: PR verificar el ciclo
                    // Navigator.pushNamedAndRemoveUntil(
                    //     SimplePrefs().navigatorKey.currentContext!,
                    //     ProductInventoryScreen.routeName,
                    //         (route) => false
                    // ),
                    Navigator.pop(context),
                    color: ColorsJunghanns.blueJ,
                    label: "OK",
                    width: double.infinity,
                    colorDotted: ColorsJunghanns.white,
                    radius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
