import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';

import '../styles/text.dart';

class WithoutInternet extends StatelessWidget {
  const WithoutInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: ColorsJunghanns.red,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: const Text(
          "Sin conexión a internet",
          style: TextStyles.white14_5,
        ));
  }
}
