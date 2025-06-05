import 'package:flutter/material.dart';
import 'package:junghanns/styles/text.dart';

import 'package:flutter/material.dart';
import 'package:junghanns/styles/text.dart';

import '../../styles/color.dart'; // Asegúrate de importar donde esté ColorsJunghanns

class EnOfRouteView extends StatelessWidget {
  const EnOfRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // O el color que uses de fondo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              Icons.arrow_back_ios,
              color: ColorsJunghanns.blue,
            ),
          ),
        ),
        title: Text(
          '',
          style: JunnyText.grey_255(FontWeight.w500, 18),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/route.jpeg",
              height: MediaQuery.of(context).size.height * .2,
            ),
            const SizedBox(height: 16),
            Text(
              "Has finalizado la ruta.",
              style: JunnyText.grey_255(FontWeight.w500,18),
            ),
            Text(
              "No es posible realizar más acciones.",
              style: JunnyText.grey_255(FontWeight.w400, 13),
            ),
          ],
        ),
      ),
    );
  }
}

/*Widget endOfRoute(BuildContext context) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/route.png",
          height: MediaQuery.of(context).size.height * .2,

        ),
        const SizedBox(
          width: double.infinity,
        ),
        *//*Text(
          "¡Upps!",
          style: JunnyText.grey_255(FontWeight.w500, 22),
        ),*//*
        Text(
          "Has finalizado la ruta.",
          style: JunnyText.grey_255(FontWeight.w500, 13),
        ),
        Text(
          "No es posible generar más registros.",
          style: JunnyText.grey_255(FontWeight.w400, 13),
        ),
      ]);
}*/
