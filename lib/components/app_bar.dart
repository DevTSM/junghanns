import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

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
    ]: [
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(right: 15),
        child: Text(
          "${prefs.labelCedis} V$version",
          style: TextStyles.blue18SemiBoldIt,
        ),
      ),
      Consumer<ProviderJunghanns>(
        builder: (_, socketProvider, __) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SizedBox(
              width: 30,
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: FaIcon(
                      FontAwesomeIcons.mobileScreenButton,
                      color: ColorsJunghanns.blue,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: socketProvider.isConnected ? ColorsJunghanns.green : ColorsJunghanns.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],

  elevation: 0,
  );
}
