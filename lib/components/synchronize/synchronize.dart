import 'package:flutter/material.dart';
import 'package:junghanns/styles/text.dart';

Widget synchronize(BuildContext context) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/synchronize.png",
          height: MediaQuery.of(context).size.height * .25,

        ),
        const SizedBox(
          width: double.infinity,
        ),
        Text(
          "¡Casi listo!",
          style: JunnyText.grey_255(FontWeight.w500, 22),
        ),
       /* Text(
          "Casi listo,",
          style: JunnyText.grey_255(FontWeight.w400, 13),
        ),*/
        Text(
          "Solo te falta una sincronización pendiente.",
          style: JunnyText.grey_255(FontWeight.w400, 13),
        ),

        /*Text(
          "¡Upps! hay información que mostrar",
          style: JunnyText.grey_255(FontWeight.w400, 16),
        )*/
      ]);
}
