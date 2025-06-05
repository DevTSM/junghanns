import 'dart:convert';

import '../../util/push_notifications_provider.dart';

class PushNotificationModel {
  String id;
  String title;
  String message;
  String code;

  PushNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.code,
  });

  // Método para mostrar la notificación
  void showNotification() {
    NotificationService().showNotifications(title, message);
  }

  void logNotification() {
    print("Código: $code");
    print("Mensaje: $message");
  }

  static PushNotificationModel fromJson(dynamic data) {
    Map<String, dynamic> jsonData;

    if (data is String) {
      try {
        jsonData = jsonDecode(data);
      } catch (e) {
        jsonData = {
          "code": "400",
          "message": "Error al procesar los datos."
        };
      }
    } else {
      jsonData = data as Map<String, dynamic>;
    }

    String id = jsonData['id'].toString();
    String message = jsonData['message'] ?? "Mensaje desconocido.";
    String title = jsonData['title'] ?? "Notificación";
    String code = jsonData['code'].toString();

    return PushNotificationModel( id: id, title: title, message: message, code: code);
  }
}
