import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../pages/socket/socket_service.dart';

class ChatProvider with ChangeNotifier {
  late IO.Socket socket;
  List<Map<String, String>> messages = [];
  final String myUserId = "user123";

  bool _hasNewMessage = false;
  bool get hasNewMessage => _hasNewMessage;

  ChatProvider() {
    socket = SocketService().getSocket(); // Usa la conexión global
    _setupListeners();
  }

  void _setupListeners() {
    socket.on("receiveMessage", (data) {
      if (data is Map<String, dynamic> && data["message"] != null) {
        messages.add({
          "text": data["message"],
          "userId": data["userId"] ?? "desconocido",
        });

        _hasNewMessage = true;
        notifyListeners();
      }
    });

    socket.onConnect((_) => print("✅ Conectado al chat"));
    socket.onDisconnect((_) => print("❌ Desconectado del chat"));
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      socket.emit("sendMessage", {"message": message, "userId": myUserId});
      messages.add({"text": message, "userId": myUserId});
      _hasNewMessage = false;
      notifyListeners();
    }
  }

  void resetNewMessageFlag() {
    _hasNewMessage = false;
    notifyListeners();
  }
}

/*class ChatProvider with ChangeNotifier {
  late IO.Socket socket;
  List<Map<String, String>> messages = [];
  final String myUserId = "user123"; // Simula un ID de usuario

  bool _hasNewMessage = false; // Nueva propiedad para el punto rojo
  bool get hasNewMessage => _hasNewMessage; // Getter para acceder a la propiedad

  bool _isConnected = false; // Variable para manejar la conexión

  bool get isConnected => _isConnected; // Getter para acceso al estado de conexión

  ChatProvider() {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io("http://192.168.0.16:3000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    socket.connect();

    socket.on("receiveMessage", (data) {
      if (data is Map<String, dynamic> && data["message"] != null) {
        messages.add({
          "text": data["message"],
          "userId": data["userId"] ?? "desconocido",
        });

        _hasNewMessage = true; // Se marca como nuevo mensaje
        notifyListeners();

        Activar el servicio de notificación al recibir el mensaje
        NotificationService _notificationService = NotificationService();
        _notificationService.showNotifications("Nuevo mensaje", data["message"]);
      }
    });

    // Escucha el evento junny_notify para mostrar notificación
    socket.on("junny_notify", (data) {
      if (data != null) {
        // Aquí se activa el servicio de notificación cuando se recibe un mensaje
        NotificationService _notificationService = NotificationService();
        _notificationService.showNotifications("Notificación del servidor", data.toString());
      }
    });

     Escuchar el evento de desconexión
    socket.onDisconnect((_) {
      print("Desconectado del servidor");
      NotificationService _notificationService = NotificationService();
      _notificationService.showNotifications("Conexión perdida", "No se pudo conectar al servidor.");
    });

    // Escuchar el error de conexión
    socket.onConnectError((error) {
      print("Error de conexión: $error");
      NotificationService _notificationService = NotificationService();
      _notificationService.showNotifications("Error de conexión", "Ocurrió un error al intentar conectar.");
    });

    socket.onConnect((_) => print("Conectado al chat"));
    socket.onDisconnect((_) => print("Desconectado del chat"));
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      socket.emit("sendMessage", {"message": message, "userId": myUserId});
      messages.add({"text": message, "userId": myUserId});
      _hasNewMessage = false; // Al enviar el mensaje, desactivamos el nuevo mensaje
      notifyListeners();
    }
  }

  void resetNewMessageFlag() {
    _hasNewMessage = false; // Resetea el estado del nuevo mensaje
    notifyListeners();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}*/
