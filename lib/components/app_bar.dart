import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junghanns/components/modal/logout.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

PreferredSizeWidget appBarJunghanns(BuildContext context, Size size) {
  return AppBar(
    backgroundColor: ColorsJunghanns.whiteJ,
    systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: ColorsJunghanns.whiteJ,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark),
    leading: GestureDetector(
      child: Container(
          padding: const EdgeInsets.only(left: 24),
          child: Image.asset("assets/icons/menu.png")),
      onTap: () {},
    ),
    actions: [
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(right: 15),
        child: Text(
          "${urlBase != ipProd ? "Beta " : ""}V 1.0.5",
          style: TextStyles.blue18SemiBoldIt,
        ),
      ),
      GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child:Image.asset(
                  "assets/icons/workRoute.png",
                  width: size.width * .10,
                )),
                onTap: () {
                  //showConfirmLogOut(context, size);
                  showLogOut(context);
                },
              ),
    ],
    elevation: 0,
  );
}
