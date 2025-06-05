import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

Widget bottomBar(Function setIndexCurrent, int indexCurrent,BuildContext context,{bool isHome=true}) {
  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Image.asset(
          "assets/icons/menuOp1W.png",
          width: 25,
          height: 25,
        ),
        activeIcon: Image.asset(
          "assets/icons/menuOp1B.png",
          width: 24,
          height: 24,
        ),
        label: 'Inicio',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          "assets/icons/menuOp2W.png",
          width: 25,
          height: 25,
        ),
        activeIcon: Image.asset(
          "assets/icons/menuOp2B.png",
          width: 24,
          height: 24,
        ),
        label: 'Entregas',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          "assets/icons/menuOp3W.png",
          width: 25,
          height: 25,
        ),
        activeIcon: Image.asset(
          "assets/icons/menuOp3B.png",
          width: 24,
          height: 24,
        ),
        label: 'Rutas',
      ),
      BottomNavigationBarItem(
        icon: Consumer<ProviderJunghanns>(
          builder: (context, provider, child) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(
                  "assets/icons/menuOp5W.png",
                  width: 25,
                  height: 25,
                ),
                if (provider.hasUnreadNotifications)
                  ClipOval(
                    child: Container(
                      width: 13,
                      height: 13,
                      alignment: Alignment.center,
                      color: JunnyColor.red5c,
                      child: Text(
                        provider.unreadNotificationsCount.toString(),
                        style: JunnyText.bluea4(FontWeight.w400, 10).copyWith(color: JunnyColor.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        activeIcon: Consumer<ProviderJunghanns>(
          builder: (context, provider, child) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(
                  "assets/icons/menuOp5B.png",
                  width: 25,
                  height: 25,
                ),
                if (provider.hasUnreadNotifications)
                  ClipOval(
                    child: Container(
                      width: 13,
                      height: 13,
                      alignment: Alignment.center,
                      color: JunnyColor.red5c,
                      child: Text(
                        provider.unreadNotificationsCount.toString(),
                        style: JunnyText.bluea4(FontWeight.w400, 10).copyWith(color: JunnyColor.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        label: 'Notificaciones',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          "assets/icons/menuOp6W.png",
          width: 25,
          height: 25,
        ),
        activeIcon: Image.asset(
          "assets/icons/menuOp6B.png",
          width: 24,
          height: 24,
        ),
        label: 'Nuevo',
      ),

    ],
    elevation: 10,
    currentIndex: indexCurrent,
    unselectedItemColor: const Color.fromRGBO(188, 190, 192, 1),
    selectedItemColor: ColorsJunghanns.blueJ,
    onTap: (value) => isHome?setIndexCurrent(value):navigator(context,value,indexCurrent),
  );
}
navigator(BuildContext context,int index,int indexCurrent){
  Provider.of<ProviderJunghanns>(context,listen: false).getPendingNotification();
  if(index!=indexCurrent){
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(
            builder: (BuildContext context) => HomePrincipal(index: index,)), (route) => false);
  }
}
