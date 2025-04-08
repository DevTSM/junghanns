import 'package:flutter/material.dart';
import 'package:junghanns/components/modal/chat_message.dart';
import 'package:junghanns/pages/home/home.dart';
import 'package:junghanns/pages/home/routes.dart';
import 'package:junghanns/pages/home/specials.dart';
import 'package:junghanns/pages/opening.dart';

import '../pages/chat/chat.dart';
import '../pages/home/home_principal.dart';

Map<String, WidgetBuilder> getApplicationRoutes() => <String, WidgetBuilder>{
  "/": (context) => Opening(),
  '/Home': (context) => const Home(),
  '/Specials': (context) => const Specials(),
  '/Routes': (context) => const Routes(),
  //Prueba de las rutas
  '/HomePrincipal': (context) => HomePrincipal(),
  '/Chat': (context) => const ChatScreen(),
};