import 'package:flutter/material.dart';
import 'package:junghanns/components/modal/transfers.dart';
import 'package:junghanns/components/modal/yes_not.dart';
import 'package:junghanns/models/transfer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

Widget transferItem(BuildContext context,Function update,TransferModel current){
  return Container(
    padding:
              const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
          child: Row(
            children: [
              Image.asset("assets/icons/menuOp4W.png",width: 30,),
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
                            text: current.amount.toString(),
                            style: TextStyles.blue16_7),
                        TextSpan(
                          text: " - ${current.description}",
                          style: TextStyles.blue16_4,
                        )
                      ]),
                      overflow: TextOverflow.ellipsis),
                  Text("${current.route} | ${current.status}",
                      style: TextStyles.grey14_4),
                ],
              )),
              const SizedBox(width: 10,),
              Visibility(
                visible: current.type=="ENVIADA",
                child: GestureDetector(
                onTap: () => showYesNot(context, ()=>update(current,"B"), "¿Estas seguro de cancelar la solicitud?", true) ,
                child: const Icon(Icons.delete,color: ColorsJunghanns.red,))),
                Visibility(
                visible: current.type!="ENVIADA",
                child: GestureDetector(
                onTap: () => showTransfer(context,update,current),
                child: const Icon(Icons.remove_red_eye,color: ColorsJunghanns.blue,)))
            ],
          ),
  );
}