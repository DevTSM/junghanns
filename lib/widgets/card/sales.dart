import 'package:flutter/material.dart';
import 'package:junghanns/models/operation_customer.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/styles/text.dart';
import 'package:intl/intl.dart';

class SalesCard extends StatelessWidget {
  SaleModel saleCurrent;
  SalesCard({Key? key, required this.saleCurrent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 10),
      child: Row(
        children: [
          Image.asset(
              "assets/icons/${(saleCurrent.type == "VENTA" || saleCurrent.type == "CTAMOVIL") ? "saleIcon.png" : "withLiquidIcon.png"}"),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saleCurrent.description,
                style: TextStyles.blue16_7,
              ),
              Visibility(
                  visible: (saleCurrent.type == "VENTA" ||
                      saleCurrent.type == "CTAMOVIL"),
                  child: Row(
                    children: [
                      Text(
                        "Cantidad: ${saleCurrent.count} \$${saleCurrent.amount}",
                        style: TextStyles.grey14_4,
                      ),
                    ],
                  )),
              Text(DateFormat('yyyy-MM-dd | HH:mm').format(saleCurrent.date),
                  style: TextStyles.grey14_4),
            ],
          )),
        ],
      ),
    );
  }
}
class OperationsCard extends StatelessWidget {
  OperationCustomerModel current;
  OperationsCard({Key? key, required this.current}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 10),
      child: Row(
        children: [
          Image.asset(
              "assets/icons/saleIcon.png"),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                current.description,
                style: TextStyles.blue16_7,
              ),
              Row(
                    children: [
                      Text(
                        "Cantidad: ${current.amount} \$${current.total}",
                        style: TextStyles.grey14_4,
                      ),
                    ],
                  ),
              Text(DateFormat('yyyy-MM-dd | HH:mm').format(current.date),
                  style: TextStyles.grey14_4),
            ],
          )),
        ],
      ),
    );
  }
}
