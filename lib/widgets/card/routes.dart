import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/pages/customer/details2.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

import '../../components/endOfRoute/end_of_route.dart';
import '../../models/authorization.dart';
import '../../preferences/global_variables.dart';
import '../../services/store.dart';

class RoutesCard extends StatelessWidget {
  Function updateList;
  Widget icon;
  CustomerModel customerCurrent;
  int indexHome;
  final List<CustomerModel>? customers; // <-- Agregado
  RoutesCard({Key? key, required this.updateList,required this.icon, required this.customerCurrent, this.indexHome=1, this.customers})
      : super(key: key);

  late List<AuthorizationModel> authList = [];
  getAuth() async {
    authList.clear();
    await getAuthorization(customerCurrent.idClient, prefs.idRouteD)
        .then((answer) {
      log(answer.body.toString());
      if (!answer.error) {
        answer.body
            .map((e) => authList.add(AuthorizationModel.fromService(e)))
            .toList();
        customerCurrent.setAuth(authList);
      } else {
        authList.addAll(customerCurrent.auth);
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          if (prefs.statusRoute == 'FNRT') {
            if (customers == null || customers!.isEmpty) {
              /// Ruta FNRT y hay clientes no atendidos → mostrar detalle
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsCustomer2(
                    indexHome: indexHome,
                    customerCurrent: customerCurrent,
                  ),
                ),
              ).whenComplete(() => updateList());
            }
            else {
              /// Ruta FNRT y no hay clientes → mostrar fin de ruta
              await getAuth();
              if (authList.isNotEmpty) {
                /// Si authList tiene datos, abrir DetailsCustomer2
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsCustomer2(
                      indexHome: indexHome,
                      customerCurrent: customerCurrent,
                    ),
                  ),
                ).whenComplete(() => updateList());
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnOfRouteView(),
                  ),
                );
              }
            }
          }else {
            /// Navega al detalle del cliente si la ruta NO ha finalizado
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsCustomer2(
                  indexHome: indexHome,
                  customerCurrent: customerCurrent,
                ),
              ),
            ).whenComplete(() => updateList());
          }
        },
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
