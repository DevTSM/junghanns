// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Size size;
  @override
  void initState(){
    super.initState();
    getPermission();
  }
  getPermission() async {
    await Geolocator.requestPermission();
  }
  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                deliveryMenZone(),
                const SizedBox(
                  height: 20,
                ),
                customersZone()
              ],
            ),
          )),
    );
  }

  Widget deliveryMenZone() {
    return Container(
        decoration: Decorations.junghannsWater,
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Bienvenido",
            style: TextStyles.green17_4,
          ),
          const Text(
            "Alejandro, Martínez",
            style: TextStyles.blue27_7,
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
              child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Lunes, 24 Junio",
                          style: TextStyles.blue19_6,
                        ),
                        Text(
                          "23 clientes para visitar",
                          style: TextStyles.grey14_4,
                        )
                      ],
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: Decorations.orangeBorder5,
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: RichText(
                          text: const TextSpan(children: [
                        TextSpan(text: "Ruta", style: TextStyles.white17_5),
                        TextSpan(text: "   10", style: TextStyles.white27_7)
                      ])))),
            ],
          )),
        ]));
  }

  Widget customersZone() {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: ColorsJunghanns.lightBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Clientes atentidos",
              style: TextStyles.blue19_6,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  decoration: Decorations.blueBorder12,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        "assets/icons/icon1.png",
                        width: size.width * .1,
                      ),
                      Column(
                        children: const [
                          Text(
                            "47",
                            style: TextStyles.white40_7,
                          ),
                          Text(
                            "En ruta",
                            style: TextStyles.white17_6,
                          )
                        ],
                      )
                    ],
                  ),
                )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                "assets/icons/iconCheck.png",
                                width: size.width * .1,
                              ),
                              Column(
                                children: const [
                                  Text(
                                    "24",
                                    style: TextStyles.blue40_7,
                                  ),
                                  Text(
                                    "Atendidos",
                                    style: TextStyles.grey17_4,
                                  )
                                ],
                              )
                            ],
                          ),
                        ))),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            item(
                "Servicios Especiales",
                ["8 programados /", " 3 Atentidos"],
                Image.asset(
                  "assets/icons/iconCalendar.png",
                  width: size.width * .1,
                )),
            const SizedBox(
              height: 15,
            ),
            item(
                "Servicios Especiales",
                ["8 programados /", " 3 Atentidos"],
                Image.asset(
                  "assets/icons/iconWarehouse.png",
                  width: size.width * .1,
                ))
          ],
        ));
  }

  Widget item(String label, List<String> description, Widget icon) {
    return Container(
      decoration: Decorations.whiteBorder12,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 18),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyles.blue19_6),
              const SizedBox(
                height: 7,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: description[0], style: TextStyles.grey14_4),
                TextSpan(text: description[1], style: TextStyles.grey14_7)
              ]))
            ],
          )),
          icon
        ],
      ),
    );
  }
}
