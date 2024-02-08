import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/customer/details2.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
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
          margin:
              const EdgeInsets.only(left: 5, right: 5, top: 7, bottom: 7),
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          decoration: customerCurrent.ventaPermitida == 0 ?
            JunnyDecoration.orange255(13).copyWith(
              color: JunnyColor.red5c.withOpacity(.1),
              border: Border.all(color: JunnyColor.red5c)
            )
            :null,
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
