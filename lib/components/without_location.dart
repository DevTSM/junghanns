import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';

import '../styles/text.dart';

class WithoutLocation extends StatelessWidget {
  const WithoutLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: ColorsJunghanns.red,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: const Text(
          "No has proporcionado permisos de ubicación",
          style: TextStyles.white14_5,
        ));
  }
}
