import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  Map<String, dynamic> data;
  DateTime date;
  String name;
  String description;
  int status;
  int id;

  NotificationModel(
      {required this.data,
      required this.date,
      required this.name,
      required this.description,
      required this.status,
      required this.id});
  factory NotificationModel.fromState() {
    return NotificationModel(
        data: {},
        date: DateTime.now(),
        name: "Alerta",
        description: "Este mensaje debe salir en la aplicación",
        status: 0,
        id: 0);
  }
  factory NotificationModel.fromDataBase(Map<String, dynamic> data) {
    return NotificationModel(
        data: data["data"] != "" ? jsonDecode(data["data"]) : {},
        date: DateTime.parse((data["date"] ?? DateTime.now().toString())),
        name: data["name"],
        description: data["description"],
        status: data["status"],
        id: data["id"]);
  }
  factory NotificationModel.fromEvent(RemoteMessage event,{int status=0}) {
    return NotificationModel(
        data: event.data.isNotEmpty ? event.data : {},
        date: DateTime.now(),
        name: event.notification!.title ?? "Sin titulo",
        description: event.notification!.body ?? "",
        status: status,
        id: 0);
  }
  Map<String, dynamic> get getMap => {
        "data": data.isEmpty ? "" : jsonEncode(data),
        "date": date.toString(),
        "name": name,
        "description": description,
        "status": status
      };
  set updateStatus(int status)=>status=status;
}
