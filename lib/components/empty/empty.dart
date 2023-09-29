import 'package:flutter/material.dart';
import 'package:junghanns/styles/text.dart';

Widget empty(BuildContext context) {
  return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        Image.asset(
          "assets/no-data.gif",
          height: MediaQuery.of(context).size.height * .3,
        ),
        const SizedBox(
          width: double.infinity,
        ),
        Text(
          "No hay información que mostrar",
          style: JunnyText.grey_255(FontWeight.w400, 16),
        )
      ]);
}
