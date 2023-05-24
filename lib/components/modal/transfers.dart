import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/transfer.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
  class ShowTransfer extends StatelessWidget{
    final Function update;
    final TransferModel current;
  const ShowTransfer({Key? key,required this.update,required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
              padding: const EdgeInsets.all(12),
              decoration: Decorations.whiteBorder12,
              width: MediaQuery.of(context).size.width * .85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      child: RichText(text: TextSpan(
                        children: [
                          TextSpan(text: "Cantidad: ",style: TextStyles.blue15SemiBold),
                          TextSpan(text: "${current.amount}",style: TextStyles.greenJ20Bold,)
                        ]
                      ))),
                      DefaultTextStyle(
                      style: TextStyles.blue15SemiBold,
                      child: const Text("Producto: ")),
                      DefaultTextStyle(
                      style: TextStyles.greenJ20Bold,
                      child: Text(current.description)),
                      DefaultTextStyle(
                      style: TextStyles.blue18SemiBoldIt,
                      textAlign: TextAlign.center,
                      child: Text(current.observation)),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child:DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      textAlign: TextAlign.center,
                      child: const Text("¿Que deseas Hacer?"))),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          flex: 2,
                          child: ButtonJunghannsLabel(
                              width: double.infinity,
                              fun: (){
                                    Navigator.pop(context);
                                    update(current,"A");
                                  },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Aceptar")),
                      const Expanded(
                          child: SizedBox(
                        width: 15,
                      )),
                      Expanded(
                          flex: 2,
                          child: ButtonJunghannsLabel(
                              width: double.infinity,
                              fun: (){
                                    Navigator.pop(context);
                                    update(current,"R");},
                              decoration: Decorations.redCard,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Rechazar")),
                    ],
                  ),
                ],
              ),
            );
  }
  }

  showTransfer(BuildContext context,Function update,TransferModel current){
    showDialog(
    context: context,
    builder: (_) => AlertDialog(content: ShowTransfer(update:update,current: current,),),
  );
  }