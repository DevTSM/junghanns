import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/customer/details2.dart';
import 'package:junghanns/styles/text.dart';

class RoutesCard extends StatelessWidget {
  Widget icon;
  CustomerModel customerCurrent;
  RoutesCard({Key? key, required this.icon, required this.customerCurrent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsCustomer2(
                      indexHome: customerCurrent.type,
                      customerCurrent: customerCurrent,
                      type: customerCurrent.type == 1
                          ? "E"
                          : customerCurrent.type == 2
                              ? "R"
                              : customerCurrent.type == 3
                                  ? "S"
                                  : "C",
                    ))),
        child: Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
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
                        TextSpan(
                            text: customerCurrent.idClient.toString(),
                            style: TextStyles.blue16_7),
                        TextSpan(
                          text: " - ${customerCurrent.address}",
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
