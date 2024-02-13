import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';

PreferredSizeWidget appBarJunghanns(BuildContext context, Size size,ProviderJunghanns provider) {
  return AppBar(
    backgroundColor: ColorsJunghanns.whiteJ,
    systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: ColorsJunghanns.whiteJ,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark),
    leading: Builder(
          builder: (context) => GestureDetector(
      child: Container(
          padding: const EdgeInsets.only(left: 24),
          child: Image.asset("assets/icons/menu.png")),
      onTap: () =>Scaffold.of(context).openDrawer(),
    )
        ),
    actions: provider.asyncProcess?[
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(right: 15),
        child: Text(
          "${prefs.labelCedis} V$version Sincronizando",
          style: TextStyles.blue18SemiBoldIt,
        ),
      ),
      const SpinKitCircle(
        color: ColorsJunghanns.blue,
      )
    ]:[
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(right: 15),
        child: Text(
          "${prefs.labelCedis} V$version",
          style: TextStyles.blue18SemiBoldIt,
        ),
      ),
      // GestureDetector(
      //   child: const Padding(
      //     padding: EdgeInsets.only(right: 10),
      //     child: Icon(
      //       Icons.message,
      //       color: JunnyColor.green24,
      //       size: 30,
      //     )
      //   ),
      //   onTap: ()=> showChat(context)
      // ),
    ],
    elevation: 0,
  );
}
