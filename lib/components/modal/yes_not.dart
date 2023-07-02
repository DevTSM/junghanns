import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
  class YesNot extends StatelessWidget{
    final Function fun;
    final String label;
    final bool isGeneric;
  const YesNot({Key? key,required this.fun,required this.label,required this.isGeneric}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
              padding: const EdgeInsets.all(12),
              decoration: Decorations.whiteBorder12,
              width: MediaQuery.of(context).size.width * .85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      textAlign: TextAlign.center,
                      child: Text(isGeneric?label:"¿Seguro que quieres ${label=="fin"?"finalizar la ruta?":label=="inicio_comida"?"iniciar el horario de comida?":"realizar esta acción?"}")),
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
                                    fun();
                                  },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Si")),
                      const Expanded(
                          child: SizedBox(
                        width: 15,
                      )),
                      Expanded(
                          flex: 2,
                          child: ButtonJunghannsLabel(
                              width: double.infinity,
                              fun: ()=>
                                    Navigator.pop(context),
                              decoration: Decorations.redCard,
                              style: TextStyles.white18SemiBoldIt,
                              label: "No")),
                    ],
                  ),
                ],
              ),
            );
  }
  }

  showYesNot(BuildContext context,Function fun,String label,bool isGeneric){
    showDialog(
    context: context,
    builder: (_) => AlertDialog(content: YesNot(fun:fun,label: label,isGeneric:isGeneric),),
  );
  }