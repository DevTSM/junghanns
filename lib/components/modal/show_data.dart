import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/billing.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
  class ShowBilling extends StatelessWidget{
    final List<BillingModel> billing;
  const ShowBilling({Key? key,required this.billing}) : super(key: key);

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
                  SingleChildScrollView(
                    child: Column(
                      children: billing.map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Nombre o Razón social: ",style: TextStyles.grey14_7),
                          Text(e.razonSocial,style: TextStyles.blue16_4),
                          const Text("RFC:",style: TextStyles.grey14_7),
                          Text(e.rfc,style: TextStyles.blue16_4),
                          const Text("Correo:",style: TextStyles.grey14_7),
                          Text(e.email,style: TextStyles.blue16_4),
                          const Text("Régimen Fiscal:",style: TextStyles.grey14_7),
                          Text(e.regimen,style: TextStyles.blue16_4),
                          const Text("Uso del CFDI: ",style: TextStyles.grey14_7),
                          Text(e.typeCFDI,style: TextStyles.blue16_4),
                          const Divider(height: 10,color: ColorsJunghanns.green,thickness: 1.2,)
                        ],
                      )
                      ).toList(),
                    ),
                  ),
                  DefaultTextStyle(
                      style: TextStyles.blueJ22Bold,
                      textAlign: TextAlign.center,
                      child: Text("")),
                  const SizedBox(
                    height: 15,
                  ),
                      ButtonJunghannsLabel(
                              width: double.infinity,
                              fun: (){
                                    Navigator.pop(context);
                                  },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Aceptar"),
                ],
              ),
            );
  }
  }

  showDataBilling(BuildContext context,List<BillingModel> billing){
    showDialog(
    context: context,
    builder: (_) => AlertDialog(content: ShowBilling(billing:billing),),
  );
  }