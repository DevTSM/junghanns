import 'dart:async';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/catalogue.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

class Cuentas extends StatefulWidget {
  int id;
  Cuentas({super.key,required this.id});

  @override
  State<StatefulWidget> createState() => _Cuentas();
}

class _Cuentas extends State<Cuentas> {
  late ProviderJunghanns provider;
  late List<Map<String, dynamic>> cuentas;
  late Size size;
  late bool isLoading;
  @override
  void initState() {
    super.initState();
    cuentas = [];
    isLoading = false;
    getData();
  }

  getData() {
    Timer(const Duration(seconds: 1), () async {
      setState(() {
        isLoading = true;
      });
      await getCuentas(widget.id).then((answer) {
        setState(() {
          isLoading = false;
        });
        if (prefs.token == "") {
          Fluttertoast.showToast(
            msg: "Las credenciales caducaron.",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
          Timer(const Duration(milliseconds: 2000), () async {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          });
        } else {
          if (answer.error) {
            Fluttertoast.showToast(
                msg: answer.message,
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
                backgroundColor: ColorsJunghanns.red);
          } else {
            cuentas.clear();
            log(answer.body.toString());
            cuentas.add({
          "clave": answer.body["cta_cable"]??"",
          "banco": answer.body["banco"]??"",
          "image": (answer.body["banco"]??"")=="Citibanamex"?
              "https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Citibanamex_logo.svg/2560px-Citibanamex_logo.svg.png":"https://thecorner.eu/wp-content/uploads/2020/06/bank-generico-777x400.jpg"
        });}
        }
      });
      setState(() {
        // cuentas.clear();
        // cuentas.add({
        //   "clave": "0123456789012345",
        //   "banco": "Citibanamex",
        //   "image":
        //       "https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Citibanamex_logo.svg/2560px-Citibanamex_logo.svg.png"
        // });
        // cuentas.add({
        //   "clave": "0123456789012345",
        //   "banco": "BBVA",
        //   "image":
        //       "https://www.nicepng.com/png/detail/321-3214672_bbva-bancomer-logo-vector-bbva-bancomer-png-logo.png"
        // });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(
      children: [
        body(),
        Visibility(
          visible: isLoading, 
          child: SizedBox(
            height: size.height*.5,
            width: double.infinity,
            child:const SpinKitCircle(
              color: ColorsJunghanns.blue,
              size: 100
            )
          )
        )
      ]
    );
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: ()=> getData(),
      child: SizedBox(
        height: size.height*.5,
        width: double.infinity,
        child: !isLoading && cuentas.isEmpty
          ? empty(context)
          : Column(
              children: cuentas.map((e) => 
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: JunnyDecoration.whiteBox(5),
                    child: Column(
                      children: [
                        Image.network(
                          e["image"],
                          height: 35,
                          width: size.width * .6,
                          fit: BoxFit.fitWidth,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: JunnyDecoration.blueCEOpacity_5Blue(5),
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 5,
                            top: 3,
                            bottom: 3
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child:AutoSizeText(
                                  e["clave"],
                                  style: JunnyText.bluea4(FontWeight.w500, 18),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                )
                              ),
                                                // GestureDetector(
                                                //     onTap: () {
                                                //       Clipboard.setData(
                                                //           ClipboardData(
                                                //               text:
                                                //                   e["clave"]));
                                                //       Fluttertoast.showToast(
                                                //           msg: "Clave copiada",
                                                //           timeInSecForIosWeb: 2,
                                                //           toastLength:
                                                //               Toast.LENGTH_LONG,
                                                //           gravity:
                                                //               ToastGravity.TOP,
                                                //           webShowClose: true);
                                                //     },
                                                //     child: const Icon(
                                                //       Icons.copy,
                                                //       size: 18,
                                                //     ))
                            ],
                          )
                        )
                      ],
                    )
                  ),
                )
              ).toList(),
            )
      )
    );
  }
}
showCuentas(BuildContext context,int id){
  showDialog(
    context: context,
    builder: (_) => 
      AlertDialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
        backgroundColor: JunnyColor.white,
        content: Cuentas(id:id)
      ),
  );
}
