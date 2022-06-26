import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/customer/details.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

class RoutesCard extends StatelessWidget{
  Widget icon;
  CustomerModel customerCurrent;
  List<String> title;
  String description;
  RoutesCard({Key? key,required this.icon,required this.customerCurrent,required this.title,required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right: 15,top: 18,bottom: 10),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: 
                TextSpan(children: [
                  TextSpan(text: title[0],style: TextStyles.blue16_7),
                  TextSpan(text: title[1],style: TextStyles.blue16_4,)
                ]),overflow: TextOverflow.ellipsis),
                Text(description,style: TextStyles.grey14_4),
              ],
            )),
            const SizedBox(width: 10,),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DetailsCustomer(customerCurrent: customerCurrent))),
            child:Container(
            padding: const EdgeInsets.only(left: 10,right: 10,top: 7,bottom: 7),
            color: ColorsJunghanns.green,
            child: const Text("Atender",style: TextStyles.white17_6,),
          ))
        ],
      ),
    );
  }
}