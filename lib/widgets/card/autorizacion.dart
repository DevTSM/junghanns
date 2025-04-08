import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/modal/code_auth.dart';
import 'package:junghanns/components/modal/yes_not.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

class AuthCard extends StatelessWidget {
  Function update;
  AuthorizationModel current;
  AuthCard({Key? key,required this.update ,required this.current}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 10),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              padding: const EdgeInsets.all(10),
              color: JunnyColor.blueCE,
              child: Image.asset(
              "assets/icons/auth.png",
              width: 20,
              height: 20,
              color: JunnyColor.white,),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                current.authText,
                style: JunnyText.bluea4(FontWeight.w500, 16),
              ),
              Text(
                current.observation,
                style: JunnyText.green24(FontWeight.w500, 16),
              ),
              AutoSizeText(
                "${current.product.stock} x ${current.product.description} = ${checkDouble(current.product.price.toString())}",
                style: JunnyText.grey_255(FontWeight.w400, 14),
                maxLines: 1,
              ),
              Row(
                children:[ 
                  const Icon(Icons.location_on_outlined,color: JunnyColor.blueC2,),
                  Expanded(child:Text(
                "${current.idClient} | ${current.client.address}",
                style: JunnyText.grey_255(FontWeight.w400, 14),
              )),
              ]),
              Row(
                children:[ 
                  const Icon(Icons.person,color: JunnyColor.blueC2,),
              Expanded(child:Text(
                current.client.name,
                style: JunnyText.grey_255(FontWeight.w400, 14),
              )),
              ]),
              Row(
                children:[ 
                  const Icon(FontAwesomeIcons.clock,color: JunnyColor.blueC2,size: 18,),
              Text(
                " ${DateFormat('hh:mm a').format(current.date)}    ",
                style: JunnyText.grey_255(FontWeight.w400, 14),
              ),
              Text(
                "Id Auth: ${current.idAuth}",
                style: JunnyText.bluea4(FontWeight.w400, 14),
              ),
              
              ])
            ],
          )),
          GestureDetector(
            onTap: ()=>showYesNot(context,()=>showCodeAuth(context,update,current),"¿Estas seguro de cancelar la autorización?",true),
            child: const Icon(Icons.delete_outline,color:JunnyColor.red5c,),
          )
        ],
      ),
    );
  }
}