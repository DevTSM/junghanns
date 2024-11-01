import 'package:flutter/material.dart';
import 'package:junghanns/styles/text.dart';

Widget empty(BuildContext context) {
  return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        Image.asset(
          "assets/no.png",
          height: MediaQuery.of(context).size.height * .2,

        ),
        const SizedBox(
          width: double.infinity,
        ),
            Text(
              "¡Upps!",
              style: JunnyText.grey_255(FontWeight.w500, 22),
            ),
            Text(
              "lo siento no hay información que mostrar.",
              style: JunnyText.grey_255(FontWeight.w400, 18),
            ),

        /*Text(
          "¡Upps! hay información que mostrar",
          style: JunnyText.grey_255(FontWeight.w400, 16),
        )*/
      ]);
}
