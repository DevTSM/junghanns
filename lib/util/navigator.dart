import 'package:flutter/material.dart';

class NavigationService { 
  static GlobalKey<NavigatorState> navigatorKey = 
  GlobalKey<NavigatorState>();
  static BuildContext context = GlobalKey<NavigatorState>().currentContext!;
}