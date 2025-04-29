/*
import 'package:flutter/material.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../pages/socket/socket_service.dart';
import '../util/push_notifications_provider.dart';

class ChatProvider with ChangeNotifier {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = []; // Permite texto y archivos
  final String myUserId = prefs.nameUserD;

  bool _hasNewMessage = false;
  bool get hasNewMessage => _hasNewMessage;

  ChatProvider() {
    socket = SocketService().getSocket();
    _setupListeners();
  }

  void _setupListeners() {
    socket.on("receiveMessage", (data) {
      if (data is Map<String, dynamic>) {
        // ✅ Evitar duplicados
        bool exists = messages.any((msg) =>
        msg["type"] == data["type"] &&
            msg["userId"] == data["user"] &&
            (msg["text"] == data["message"] || msg["fileName"] == data["fileName"]));

        if (!exists) {
          messages.add({
            "type": data["type"],
            "userId": data["user"] ?? "desconocido",
            "text": data["message"] ?? "",
            "fileName": data["fileName"],
            "fileType": data["fileType"],
            "fileBase64": data["fileBase64"],
          });

          _hasNewMessage = true;
          notifyListeners();
        }

        // 📢 Si el mensaje viene del servidor, podrías manejarlo de forma distinta
        if (data["user"] != myUserId) {
          print("📢 Mensaje del servidor: ${data['message']}");

          // Si el mensaje es de tipo archivo
          if (data["type"] == "file") {
            // Mostrar la notificación para archivos
            NotificationService().showNotifications(
                "Nuevo archivo del Servidor",
                "Archivo recibido: ${data['fileName']}");
          } else {
            // Mostrar la notificación para texto
            NotificationService().showNotifications(
                "Mensaje del Servidor",
                data['message'].toString());
          }
        }
      }
    });
// Escuchar la notificación "junny_notify" enviada por el servidor
    socket.on("junny_notify", (notification) {
      print("🚨 Notificación del servidor: $notification");

      // Mostrar la notificación en la interfaz
      NotificationService().showNotifications("Notificación", notification.toString());
    });
    socket.onConnect((_) => print("✅ Conectado al chat"));
    socket.onDisconnect((_) => print("❌ Desconectado del chat"));
  }

  // 📩 Enviar mensaje de texto
  void sendMessage(String message) {
    if (message.isNotEmpty) {
      final data = {"type": "text", "message": message, "user": myUserId};
      socket.emit("sendMessage", data);

      messages.add(data);
      _hasNewMessage = true;
      notifyListeners();
    }
  }

  // 📂 Enviar archivo
  *//*

*/
/*void sendFile(String fileName, String fileType, String fileBase64) {
    final data = {
      "type": "file",
      "fileName": fileName,
      "fileType": fileType,
      "fileBase64": fileBase64,
      "user": myUserId
    };

    socket.emit("sendMessage", data);

    // ❌ No agregar manualmente el mensaje aquí para evitar duplicados
     messages.add(data);

    _hasNewMessage = true;
    notifyListeners();
  }*//*
*/
/*


  void sendFile(String fileName, String fileType, String fileBase64) {
    if (myUserId.isEmpty) {
      print("⚠️ Error: userId vacío, no se enviará el archivo.");
      return;
    }

    final data = {
      "type": "file",
      "fileName": fileName,
      "fileType": fileType,
      "fileBase64": fileBase64,
      "user": myUserId // Asegurar que se envía correctamente
    };

    print("📤 Enviando archivo con userId: ${myUserId}");

    socket.emit("sendMessage", data);
    messages.add(data);

    _hasNewMessage = true;
    notifyListeners();
  }

  void resetNewMessageFlag() {
    _hasNewMessage = false;
    notifyListeners();
  }
}
*//*

import 'package:flutter/material.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../pages/socket/socket_service.dart';
import '../util/push_notifications_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class ChatProvider with ChangeNotifier {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = []; // Permite texto y archivos
  final String myUserId = prefs.nameUserD;

  bool _hasNewMessage = false;
  bool get hasNewMessage => _hasNewMessage;

  ChatProvider() {
    socket = SocketService().getSocket();
    _setupListeners();
  }
  void _setupListeners() {
    socket.on("receiveMessage", (data) {
      if (data is Map<String, dynamic>) {
        // Evitar duplicados de mensajes
        bool exists = messages.any((msg) =>
        msg["type"] == data["type"] &&
            msg["userId"] == data["user"] &&
            (msg["message"] == data["message"] || msg["fileName"] == data["fileName"]));

        if (!exists) {
          // Si el mensaje proviene del servidor, lo manejamos de manera especial
          if (data["user"]
          != myUserId) {
            messages.add({
              "type": data["type"],
              "userId": "Servidor",  // Esto asegura que el mensaje sea identificado como del servidor
              "message": data["message"] ?? "",
              "fileName": data["fileName"],
              "fileType": data["fileType"],
              "fileUrl": data["fileUrl"],
            });

            NotificationService().showNotifications(
              "Nuevo mensaje de ${data["userId"]}",
              data["message"] ?? "Nuevo mensaje recibido",
            );

            // Solo marcar como nuevo mensaje si no es del usuario actual
            _hasNewMessage = true;
            notifyListeners();  // Notificar que el estado ha cambiado
          } else {
            // Si el mensaje proviene del usuario, lo agregamos normalmente
            messages.add({
              "type": data["type"],
              "userId": data["user"] ?? "desconocido",
              "message": data["message"] ?? "",
              "fileName": data["fileName"],
              "fileType": data["fileType"],
              "fileUrl": data["fileUrl"],
            });
          }

          */
/*_hasNewMessage = true;
          notifyListeners();  // Notificar que el estado ha cambiado*//*

        }
      }
    });
  }

  // 📩 Enviar mensaje de texto
  void sendMessage(String message) {
    if (message.isNotEmpty) {
      final data = {"type": "text", "message": message, "user": myUserId};
      socket.emit("sendMessage", data);  // Enviar al servidor

      // Agregar el mensaje a la lista localmente para que se vea inmediatamente
      messages.add({
        "type": "text",
        "message": message,
        "userId": myUserId,  // Asegúrate de que el 'userId' sea el correcto
      });

      */
/*_hasNewMessage = true;*//*

      notifyListeners();  // Notificar para actualizar la UI
    }
  }


  // 📂 Enviar archivo mediante API REST
  Future<void> sendFile(String filePath) async {
    try {
      final uri = Uri.parse("http://192.168.0.15:3000/send-message");
      final request = http.MultipartRequest("POST", uri);

      // Adjuntar archivo
      var file = await http.MultipartFile.fromPath("file", filePath);
      request.files.add(file);

      // Enviar petición
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(await response.stream.bytesToString());

        // Agregar a mensajes solo si la API responde correctamente
        messages.add({
          "type": "file",
          "userId": myUserId,
          "fileName": basename(filePath),
          "fileType": lookupMimeType(filePath),
          "fileUrl": responseData["data"]["fileUrl"],
        });

        _hasNewMessage = true;
        notifyListeners();
      } else {
        print("⚠️ Error al enviar archivo: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error al subir el archivo: $e");
    }
  }

  void resetNewMessageFlag() {
    _hasNewMessage = false;
    notifyListeners();
  }
}
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/chat/chat_model.dart';
import 'package:junghanns/models/chat/message_model.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/chat.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/validation_product.dart';
import '../pages/socket/socket_service.dart';
import '../util/push_notifications_provider.dart';

class NotificationsProvider with ChangeNotifier {
  late IO.Socket socket;

  bool _hasNewMessage = false;
  bool get hasNewMessage => _hasNewMessage;

  NotificationsProvider() {
    socket = SocketService().getSocket();

  }

  List<ValidationProductModel> _validationList = [];


  List<ValidationProductModel> get validationList => _validationList;


  set validationList(List<ValidationProductModel> current) {
    _validationList = current;
    notifyListeners();
  }

  fetchStockValidation() async {

    await getValidationList(idR: prefs.idRouteD).then((answer) {

      if (answer.error) {
        Fluttertoast.showToast(
          msg: "${answer.message}",
          timeInSecForIosWeb: 16,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        if (answer.body is List) {
          validationList = (answer.body as List)
              .map((item) => ValidationProductModel.fromJson(item))
              .toList();
        } else if (answer.body is Map) {
          final validation = ValidationProductModel.fromJson(answer.body);
          validationList = [validation];
        }


        /*print("Lista de validaciones obtenida: ${validationList.length} items.");
        // Imprimir cada validación para depuración
        for (var validation in validationList) {
          print(validation);
        }
        print("---Llamando--");*/
      }
    });
    notifyListeners();
  }

  void resetNewMessageFlag() {
    _hasNewMessage = false;
    notifyListeners();
  }
}
