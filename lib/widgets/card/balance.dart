import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/styles/text.dart';

Widget itemBalance(String image, String label, double count,double width) {
  NumberFormat formatMoney = NumberFormat("\$#,##0.00");
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: SizedBox(
        width: width/3,
        height: width/3,
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        const SizedBox(
          height: 10,
        ),
        Image.asset(
          "assets/icons/$image",
          width: (width)/7,
          height: (width)/7,
        ),
        const SizedBox(
          height: 5,
        ),
        Expanded(
          flex:2,
          child: AutoSizeText(
          formatMoney.format(count),
          style: TextStyles.blue27_7,
          maxLines: 1,
        )),
        Expanded(
          flex:1,
          child:AutoSizeText(label, style: TextStyles.grey14_7)),
        const SizedBox(
          height: 10,
        ),
      ])),
    );
  }