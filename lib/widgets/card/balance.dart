import 'package:flutter/material.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/styles/text.dart';

Widget itemBalance(String image, String label, double count,double width) {
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
        Expanded(child:Image.asset(
          "assets/icons/$image",
        )),
        const SizedBox(
          height: 5,
        ),
        Text(
          checkDouble(count.toString()),
          style: TextStyles.blue27_7,
        ),
        Text(label, style: TextStyles.grey14_7),
        const SizedBox(
          height: 10,
        ),
      ])),
    );
  }