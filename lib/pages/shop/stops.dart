import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/styles/decoration.dart';

import '../../components/button.dart';
import '../../services/store.dart';
import '../../styles/color.dart';
import '../../styles/text.dart';

class Stops extends StatefulWidget {
  const Stops({Key? key}) : super(key: key);

  @override
  State<Stops> createState() => _StopsState();
}

class _StopsState extends State<Stops> {
  late Size size;
  late List<StopModel> stopList = [];
  late int stopSelect = -1;

  @override
  void initState() {
    super.initState();
    getDataStops();
  }

  getDataStops() async {
    await getStopsList().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        stopList.clear();
        setState(() {
          answer.body
              .map((e) => stopList.add(StopModel.fromService(e)))
              .toList();
        });
        /*stopList.add(StopModel(
            name: "No estuvo",
            img: "assets/images/stop1.png",
            id: 0,
            isSelect: false));
        stopList.add(StopModel(
            name: "Todavia tiene",
            img: "assets/images/stop2.png",
            id: 1,
            isSelect: false));
        stopList.add(StopModel(
            name: "No recibió",
            img: "assets/images/stop3.png",
            id: 2,
            isSelect: false));
        stopList.add(StopModel(
            name: "No tiene dinero",
            img: "assets/images/stop4.png",
            id: 3,
            isSelect: false));
        stopList.add(StopModel(
            name: "Ya es tarde",
            img: "assets/images/stop5.png",
            id: 4,
            isSelect: false));
        stopList.add(StopModel(
            name: "Vacaciones",
            img: "assets/images/stop6.png",
            id: 5,
            isSelect: false));
        stopList.add(StopModel(
            name: "Cancela servico",
            img: "assets/images/stop7.png",
            id: 6,
            isSelect: false));*/
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
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
        color: ColorsJunghanns.whiteJ,
        child: Column(
          children: [fakeStop(), typesOfStops(), buttonSelectStop()],
        ),
      ),
    );
  }

  Widget buttonSelectStop() {
    return Visibility(
        visible: stopSelect != -1 ? true : false,
        child: Container(
            margin:
                const EdgeInsets.only(left: 15, right: 15, bottom: 30, top: 30),
            width: double.infinity,
            height: 40,
            alignment: Alignment.center,
            child: ButtonJunghanns(
              decoration: Decorations.blueBorder12,
              fun: () => funSelectStop(),
              label: "Seleccionar parada",
              style: TextStyles.white17_5,
            )));
  }

  funSelectStop() {
    log("Parada numero $stopSelect");
    Navigator.pop(context);
  }

  Widget fakeStop() {
    return Container(
        padding: EdgeInsets.only(
            right: 10, left: 15, top: 10, bottom: size.height * .02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorsJunghanns.blueJ,
                )),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parada en Falso",
                          style: TextStyles.blueJ30BoldIt,
                        ),
                        Text(
                          "  Nombre de cliente Ruta",
                          style: TextStyles.green18Itw,
                        ),
                      ],
                    ))),
          ],
        ));
  }

  Widget stop(String image, String text, int id) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(4),
          decoration:
              stopSelect == id ? Decorations.blueCard : const BoxDecoration(),
          child: Column(
            children: [
              Expanded(flex: 3, child: Image.asset(image)),
              Expanded(
                  flex: 1,
                  child: Container(
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        text,
                        style: TextStyles.grey17Itw,
                        textAlign: TextAlign.center,
                      )))
            ],
          )),
      onTap: () {
        log("Parada en falso");
        setState(() {
          if (stopSelect != id) {
            stopSelect = id;
          } else {
            stopSelect = -1;
          }
        });
      },
    );
  }

  Widget typesOfStops() {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            margin: const EdgeInsets.only(top: 20),
            child: GridView.custom(
              gridDelegate: SliverWovenGridDelegate.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 15,
                pattern: const [
                  WovenGridTile(.8),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) => stop(stopList[index].icon,
                    stopList[index].description, stopList[index].id),
                childCount: stopList.length,
              ),
            )));
  }
}
