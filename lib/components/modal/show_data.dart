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
              //padding: const EdgeInsets.all(12),
              //decoration: Decorations.whiteBorder12,
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
                          Text(
                            "Nombre o Razón social: ",
                            style: JunnyText.grey_255(FontWeight.w500, 12)
                          ),
                          Text(
                            e.razonSocial,
                            style: JunnyText.bluea4(FontWeight.w400, 14)
                          ),
                          Text(
                            "RFC:",
                            style: JunnyText.grey_255(FontWeight.w500, 12)
                          ),
                          Text(
                            e.rfc,
                            style: JunnyText.bluea4(FontWeight.w400, 14)
                          ),
                          Text(
                            "Correo:",
                            style: JunnyText.grey_255(FontWeight.w500, 12)
                          ),
                          Text(
                            e.email,
                            style: JunnyText.bluea4(FontWeight.w400, 14)
                          ),
                          Text(
                            "Régimen Fiscal:",
                            style: JunnyText.grey_255(FontWeight.w500, 12)
                          ),
                          Text(
                            e.regimen,
                            style: JunnyText.bluea4(FontWeight.w400, 14)
                          ),
                          Text(
                            "Uso del CFDI: ",
                           style: JunnyText.grey_255(FontWeight.w500, 12)
                          ),
                          Text(
                            e.typeCFDI,
                            style: JunnyText.bluea4(FontWeight.w400, 14)
                          ),
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
                              label: "Cerrar"),
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