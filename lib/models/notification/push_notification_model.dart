import 'dart:convert';

import '../../util/push_notifications_provider.dart';

class PushNotificationModel {
  String title;
  String message;
  String code; // Aquí guardaremos el código que llega del servidor

  PushNotificationModel({
    required this.title,
    required this.message,
    required this.code, // Requerido para asegurarnos de que siempre viene un código
  });

  // Método para mostrar la notificación
  void showNotification() {
    NotificationService().showNotifications(title, message);
  }

  // Método para mostrar el código y mensaje en la consola
  void logNotification() {
    print("Código: $code");
    print("Mensaje: $message");
  }

  // Método para crear una instancia de la notificación a partir de un JSON
  static PushNotificationModel fromJson(dynamic data) {
    Map<String, dynamic> jsonData;

    if (data is String) {
      try {
        jsonData = jsonDecode(data); // Intenta decodificar el string a JSON
      } catch (e) {
        // Si no es un JSON válido, configuramos un valor predeterminado
        jsonData = {
          "code": "400", // Si hay error, asignamos código 400
          "message": "Error al procesar los datos."
        };
      }
    } else {
      jsonData = data as Map<String, dynamic>; // Si ya es un Map, lo usamos tal cual
    }

    // Extraer el 'message' y 'code' del JSON, asegurándonos de que el 'code' sea un String
    String message = jsonData['message'] ?? "Mensaje desconocido."; // Valor por defecto
    String title = jsonData['title'] ?? "Notificación"; // Valor por defecto para el título
    String code = jsonData['code'].toString(); // Convertir 'code' a String si es un número

    return PushNotificationModel(title: title, message: message, code: code);
  }
}
