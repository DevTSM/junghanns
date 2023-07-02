import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';

import '../styles/text.dart';

class NeedAsync extends StatelessWidget {
  const NeedAsync({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: ColorsJunghanns.yellow,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: const Text(
          "Necesitas sincronizar",
          style: TextStyles.white14_5,
        ));
  }
}
