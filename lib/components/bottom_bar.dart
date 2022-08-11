import 'package:flutter/material.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/styles/color.dart';

Widget bottomBar(Function setIndexCurrent, int indexCurrent,{BuildContext? context,bool isHome=true}) {
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
        label: 'Especial',
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
        icon: Image.asset(
          "assets/icons/menuOp4W.png",
          width: 25,
          height: 25,
        ),
        activeIcon: Image.asset(
          "assets/icons/menuOp4B.png",
          width: 24,
          height: 24,
        ),
        label: '2° Vuelta',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          "assets/icons/menuOp5W.png",
          width: 25,
          height: 25,
        ),
        activeIcon: Image.asset(
          "assets/icons/menuOp5B.png",
          width: 24,
          height: 24,
        ),
        label: 'LLamadas',
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
    onTap: (value) => isHome?setIndexCurrent(value):navigator(context!,value,indexCurrent),
  );
}
navigator(BuildContext context,int index,int indexCurrent){
  if(index!=indexCurrent){
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(
            builder: (BuildContext context) => HomePrincipal(index: index,)), (route) => false);
  }
}
