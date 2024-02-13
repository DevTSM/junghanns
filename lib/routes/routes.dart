import 'package:flutter/material.dart';
import 'package:junghanns/pages/home/home.dart';
import 'package:junghanns/pages/home/routes.dart';
import 'package:junghanns/pages/home/specials.dart';
import 'package:junghanns/pages/opening.dart';

Map<String, WidgetBuilder> getApplicationRoutes() => <String, WidgetBuilder>{
  "/": (context) => Opening(),
  '/Home': (context) => const Home(),
  '/Specials': (context) => const Specials(),
  '/Routes': (context) => const Routes(),
};