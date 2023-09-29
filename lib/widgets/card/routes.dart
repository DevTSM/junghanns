import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/customer/details2.dart';
import 'package:junghanns/styles/text.dart';

class RoutesCard extends StatelessWidget {
  Function updateList;
  Widget icon;
  CustomerModel customerCurrent;
  int indexHome;
  RoutesCard({Key? key, required this.updateList,required this.icon, required this.customerCurrent, this.indexHome=1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsCustomer2(
                      indexHome: indexHome,
                      customerCurrent: customerCurrent,
                    ),)).whenComplete(()=>updateList()),
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
                  Text("N.T. ${customerCurrent.id}",
                      style: TextStyles.grey12_4),
                ],
              )),
            ],
          ),
        ));
  }
}
