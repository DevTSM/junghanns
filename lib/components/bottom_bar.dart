import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';
import 'package:provider/provider.dart';

import '../pages/chat/chat.dart';
import '../provider/chat_provider.dart';
/*Widget bottomBar(Function setIndexCurrent, int indexCurrent, BuildContext context, {bool isHome = true}) {
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
          children: [
            Image.asset(
              "assets/icons/menuOp5W.png",
              width: 25,
              height: 25,
            ),
            Visibility(
              visible: Provider.of<ProviderJunghanns>(context, listen: false).isNotificationPending,
              child: ClipOval(
                child: Container(
                  width: 13,
                  height: 13,
                  alignment: Alignment.center,
                  color: JunnyColor.red5c,
                  child: Text(
                    Provider.of<ProviderJunghanns>(context, listen: false).totalNotificationPending.toString(),
                    style: JunnyText.bluea4(FontWeight.w400, 10).copyWith(color: JunnyColor.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        activeIcon: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.asset(
              "assets/icons/menuOp5B.png",
              width: 25,
              height: 25,
            ),
            Visibility(
              visible: Provider.of<ProviderJunghanns>(context, listen: false).isNotificationPending,
              child: ClipOval(
                child: Container(
                  width: 13,
                  height: 13,
                  alignment: Alignment.center,
                  color: JunnyColor.red5c,
                  child: Text(
                    Provider.of<ProviderJunghanns>(context, listen: false).totalNotificationPending.toString(),
                    style: JunnyText.bluea4(FontWeight.w400, 10).copyWith(color: JunnyColor.white),
                  ),
                ),
              ),
            ),
          ],
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
      BottomNavigationBarItem(
        icon: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                FaIcon(
                  FontAwesomeIcons.comment, // Ícono de chat de FontAwesome
                  size: 22,
                  color: Colors.grey, // Ícono gris cuando está inactivo
                ),
                if (chatProvider.hasNewMessage)
                  Positioned(
                    right: -3,
                    top: 0,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        activeIcon: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const FaIcon(
                  FontAwesomeIcons.comment, // Ícono de chat de FontAwesome
                  size: 22,
                  color: Colors.grey, // Ícono gris cuando está inactivo
                ),
                if (chatProvider.hasNewMessage)
                  Positioned(
                    right: -5,
                    top: 0,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        label: 'Chat',
      ),

    ],
    elevation: 10,
    currentIndex: indexCurrent,
    unselectedItemColor: const Color.fromRGBO(188, 190, 192, 1),
    selectedItemColor: ColorsJunghanns.blueJ,
    onTap: (value) {
      if (value == 5) {
        Provider.of<ChatProvider>(context, listen: false).resetNewMessageFlag();
        _openChatModal(context);
        // Abrir el Chat como un modal cuando se selecciona la opción de 'Chat'

         *//*showDialog(
          context: context,
          barrierDismissible: true, // Permite cerrar el diálogo al tocar fuera
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,  // Fondo transparente
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // Bordes redondeados con ClipRRect
              child: Container(
                width: 350, // Ancho ajustado
                height: 600, // Altura ajustada
                child: ChatScreen(), // Aquí se carga la vista del Chat
              ),
            ),
          ),
        ).whenComplete(() {
          // Aquí puedes hacer algo después de cerrar el diálogo si es necesario
        });*//*

      } else {
        // Para las otras opciones de navegación
        isHome ? setIndexCurrent(value) : navigator(context, value, indexCurrent);
      }
    },
   // onTap: (value) => isHome ? setIndexCurrent(value) : navigator(context, value, indexCurrent),
  );
}

void _openChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,  // Permite que la modal se ajuste al contenido
    backgroundColor: Colors.transparent, // Fondo transparente para bordes redondeados
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: .96,  // Inicia ocupando el 100% de la pantalla
        minChildSize: 0.8, // Tamaño mínimo (80% de la pantalla, ajustable)
        maxChildSize: 1.0, // Tamaño máximo (100% de la pantalla)
        expand: true, // Permite que la modal se expanda completamente
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ChatScreen(),  // Coloca el chat dentro de la modal
          );
        },
      );
    },
  );
}*/


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
                  width: 13,
                  height: 13,
                  alignment: Alignment.center,
                  color: JunnyColor.red5c,
                  child: Text(
                    Provider.of<ProviderJunghanns>(context,listen: false)
                      .totalNotificationPending.toString(),
                    style: JunnyText.bluea4(FontWeight.w400, 10)
                      .copyWith(color: JunnyColor.white)
                  ),
                  ),
                )
              )
            ]
          ),
        activeIcon:Stack(
          alignment: Alignment.topRight,
          children:[
            Image.asset(
              "assets/icons/menuOp5B.png",
              width: 25,
              height: 25,
            ),
            Visibility(
              visible:Provider.of<ProviderJunghanns>(context,listen: false).isNotificationPending,
              child: ClipOval(
                child: Container(
                  width: 13,
                  height: 13,
                  alignment: Alignment.center,
                  color: JunnyColor.red5c,
                  child: Text(
                    Provider.of<ProviderJunghanns>(context,listen: false)
                      .totalNotificationPending.toString(),
                    style: JunnyText.bluea4(FontWeight.w400, 10)
                      .copyWith(color: JunnyColor.white)
                  ),
                  ),
                )
              )
            ]
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
