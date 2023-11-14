import 'package:flutter/material.dart';
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
        icon: Stack(
          alignment: Alignment.topRight,
          children:[
            Image.asset(
              "assets/icons/menuOp5W.png",
              width: 25,
              height: 25,
            ),
            Visibility(
              visible:Provider.of<ProviderJunghanns>(context,listen: false).isNotificationPending,
              child: ClipOval(
                child: Container(
                  width: 12,
                  height: 12,
                  alignment: Alignment.center,
                  color: JunnyColor.red5c,
                  child: Text(Provider.of<ProviderJunghanns>(context,listen: false).totalNotificationPending.toString(),style: JunnyText.bluea4(FontWeight.w400, 10)
                      .copyWith(color: JunnyColor.white)
                  ),
                  ),
                )
              )
            ]
          ),
        activeIcon:Image.asset(
          "assets/icons/menuOp5B.png",
          width: 25,
          height: 25,
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
