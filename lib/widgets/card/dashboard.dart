import 'package:flutter/material.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

Widget customersType(String icon,String type,String atendidos, String enRuta) {
  return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8,left: 10,right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child:Image.asset(
              icon,
              color: ColorsJunghanns.green,
              width: 30,
            )),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: TextSpan(
                  children: [
                    TextSpan(
                      text: enRuta,
                      style: TextStyles.blue40_7
                    ),
                    TextSpan(
                      text: type,
                      style: TextStyles.blue13It
                    )
                  ]
                )),
                RichText(text: TextSpan(
                  children: [
                    TextSpan(
                      text: atendidos,
                      style: TextStyles.blue19_7
                    ),
                    TextSpan(
                      text: " Atendidos",
                      style: TextStyles.blue13It
                    )
                  ]
                )),
              ],
            )
          ],
        ),
      ));
}
