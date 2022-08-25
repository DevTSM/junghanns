import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/styles/decoration.dart';

class NewCustomer extends StatefulWidget {
  const NewCustomer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewCustomerState();
}

class _NewCustomerState extends State<NewCustomer> {
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.whiteJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.whiteJ,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menu.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: Container(
          height: double.infinity,
          color: ColorsJunghanns.lightBlue,
          child: SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.only(left: 24, right: 24),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nuevo cliente",
                      style: TextStyles.blueJ22Bold,
                    ),
                    buttonLocation()
                  ],
                )),
          )),
    );
  }

  Widget buttonLocation() {
    return Container(
        margin: const EdgeInsets.only(top: 15),
        height: 35,
        child: ButtonJunghanns(
            fun: () {
              log("Fun update location");
            },
            decoration: Decorations.blueBorder12,
            style: TextStyles.white14SemiBold,
            label: "ACTUALIZAR UBICACIÓN"));
  }
}
