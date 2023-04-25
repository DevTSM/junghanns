import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/text.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRSeller extends StatefulWidget {
  const QRSeller({super.key});

  @override
  State<StatefulWidget> createState() => _QRSellerState();
}

class _QRSellerState extends State<QRSeller> {
  late Map<String, dynamic> nameCurrent;
  late List<Map<String, dynamic>> list;

  @override
  void initState() {
    super.initState();
    list = prefs.qr != "" ? List.from(jsonDecode(prefs.qr)) : [];
    if(list.length==1){
      nameCurrent=list.first;
    }else{
      nameCurrent = {"name": "Selecciona una opción"};
      list.add(nameCurrent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
            ),
            //Intrucciones
            Visibility(
                visible: nameCurrent["url"] == null||prefs.qr == "",
                child: 
                Container(
                  
                  padding: const EdgeInsets.only(top: 40, bottom: 30),
                  child: Text(prefs.qr == ""?"Ups!! no fue posible obtener la información, por favor intenta sincronizar":list.where((element) => element["url"]!=null).isEmpty?"":
                      "Por favor selecciona una opcion para poder generar el Qr",
                      style: TextStyles.blue19_4,
                      textAlign: TextAlign.center,),
                )),
            //Select
            Visibility(
              visible: prefs.qr!="",
              child: list.where((element) => element["url"]!=null).length>1
                    ? DropdownButton<Map<String, dynamic>>(
                        value: nameCurrent,
                        icon: const Icon(Icons.arrow_drop_down_sharp),
                        elevation: 5,
                        onChanged: (Map<String, dynamic>? value) {
                          if (value!["url"] != null) {
                            setState(() {
                              nameCurrent = value;
                              list.removeWhere(
                                  (element) => element["url"] == null);
                            });
                          }
                        },
                        items: list.map<DropdownMenuItem<Map<String, dynamic>>>(
                            (Map<String, dynamic> value) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: value,
                            child:
                                Text(value["name"], style: TextStyles.blue16_4),
                          );
                        }).toList(),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: Text(
                          list.where((element) => element["url"]!=null).isEmpty?"EL roll de reparto no ha sido registrado": nameCurrent["name"],
                          textAlign: TextAlign.center,
                          style: TextStyles.blue16_4,
                        ))),
            // const Expanded(
            //   child: SizedBox(
            //     height: 20,
            //     width: double.infinity,
            //   ),
            // ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              height: MediaQuery.of(context).size.width - 100,
              child: nameCurrent["url"] != null
                  ? QrImage(
                      size: MediaQuery.of(context).size.width - 100,
                      data: nameCurrent["url"],
                      gapless: true,
                      version: QrVersions.auto,
                      padding: EdgeInsets.all(10),
                      semanticsLabel: '',
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    )
                  : Container(
                        padding: EdgeInsets.only(left:MediaQuery.of(context).size.width*.15,right:MediaQuery.of(context).size.width*.15 ),
                        child:Image.asset(
                           prefs.qr==""?"assets/images/async.png":"assets/images/qr.png",
                          fit: BoxFit.contain,
                        )),
            ),
            
          ],
        ));
  }
}
