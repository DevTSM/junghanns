import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/customer/details.dart';
import 'package:junghanns/styles/text.dart';

class RoutesCard extends StatelessWidget {
  Widget icon;
  CustomerModel customerCurrent;
  RoutesCard(
      {Key? key,
      required this.icon,
      required this.customerCurrent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsCustomer(
                      indexHome: customerCurrent.type,
                      customerCurrent: customerCurrent,
                      type: customerCurrent.type==1?"E":customerCurrent.type==2?"R":customerCurrent.type==3?"S":"C",
                    ))),
        child: Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 10),
          child: Row(
            children: [
              icon,
              const SizedBox(
                width: 18,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(children: [
                        TextSpan(text: customerCurrent.idClient.toString(), style: TextStyles.blue16_7),
                        TextSpan(
                          text: " - ${customerCurrent.name}",
                          style: TextStyles.blue16_4,
                        )
                      ]),
                      overflow: TextOverflow.ellipsis),
                  Text("${customerCurrent.orden} | ${customerCurrent.name}",
                      style: TextStyles.grey14_4),
                ],
              )),
            ],
          ),
        ));
  }
}
