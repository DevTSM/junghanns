import 'dart:convert';

import 'package:junghanns/preferences/global_variables.dart';

class DashboardModel {
  List<Map<String,dynamic>> stock;

  DashboardModel(
      {required this.stock});

  factory DashboardModel.fromState() {
    return DashboardModel(
        stock: []);
  }

  factory DashboardModel.fromService(Map<String, dynamic> data) {
    prefs.dashboard = jsonEncode(data);
    return DashboardModel(
      stock: List.from(data["stock"]??[])
    );
  }
  factory DashboardModel.fromPrefs() {
    Map<String,dynamic> data = jsonDecode(prefs.dashboard);
    return DashboardModel(
      stock: List.from(data["stock"]??[])
    );
  }
}
