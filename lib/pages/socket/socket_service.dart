/*
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:device_information/device_information.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:mac_address/mac_address.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import '../../models/notification/push_notification_model.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    log("Iniciando conexión WebSocket...");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String serial = await GetMac.macAddress;
    String modelo = await DeviceInformation.deviceModel;
    if (serial.isEmpty || serial.length < 2) {
      serial = androidInfo.id ?? "";
    }

    // Crear el token utilizando la fecha actual
    String token = _generateToken();

    socket = IO.io('https://sandbox.junghanns.app:3002', <String, dynamic> {
      'auth': {
        'token': token,
        'user': prefs.nameUserD,
        'serial': serial,
        'model': modelo,
      },
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      log("Conectado con éxito como: ${prefs.nameUserD}");
      _isConnected = true;
    });

    socket.on('test_conection', (data) {
      log('Mensaje desde el servidor: $data');
      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();
      notification.logNotification();  // Imprimir código y mensaje
    });

    socket.on('respuesta', (data) {
      log('Respuesta del servidor: $data');
      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();
      notification.logNotification();  // Imprimir código y mensaje
    });

    socket.onConnectError((error) {
      log("Error de conexión: $error");
      // Mostrar solo el mensaje
      PushNotificationModel notification = PushNotificationModel(
        title: "Error de conexión",
        message: "Ocurrió un error al intentar conectar.",
        code: "500",  // Error de conexión
      );
      notification.showNotification();
      notification.logNotification();  // Imprimir código y mensaje
    });

    socket.onError((error) {
      log("Error general del socket: $error");
    });

    // Intentar reconectar después de 10 segundos si la conexión falla
    Future.delayed(Duration(seconds: 10), () {
      if (!socket.connected) {
        log("Reintentando conexión...");
        socket.connect();
      }
    });
  }

  String _generateToken() {
    // Obtener la fecha actual en formato "Ymd"
    String date = DateFormat('yyyyMMdd').format(DateTime.now());

    // Concatenar la fecha con "_jsm"
    String dataToHash = "$date" + "_jsm";

    // Crear el hash sha1
    var bytes = utf8.encode(dataToHash);  // Codificar en bytes
    var digest = sha1.convert(bytes);     // Crear el hash

    return digest.toString(); // Devolver el token generado
  }

  IO.Socket getSocket() => socket;

  bool get isConnected => _isConnected;

  void disconnect() {
    socket.disconnect();
    log("WebSocket desconectado manualmente");
  }
}
*/
import 'dart:developer';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:mac_address/mac_address.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import '../../models/notification/push_notification_model.dart';
class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;
  bool _hasShownConnectionError = false; // Para evitar múltiples toasts

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    log("Iniciando conexión WebSocket...");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String serial = await GetMac.macAddress;
    String modelo = await DeviceInformation.deviceModel;
    if (serial.isEmpty || serial.length < 2) {
      serial = androidInfo.id ?? "";
    }

    String token = _generateToken();

    socket = IO.io('https://sandbox.junghanns.app:4102', <String, dynamic>{
      'auth': {
        'token': token,
        'user': prefs.nameUserD,
        'serial': serial,
        'model': modelo,
      },
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      log("Conectado con éxito como: ${prefs.nameUserD}");
      _isConnected = true;
      _hasShownConnectionError = false;
    });

    socket.on('test_conection', (data) {
      log('Mensaje desde el servidor: $data');
      _showToast("Mensaje: ${data['message']}", ColorsJunghanns.green);
    });

    socket.on('respuesta', (data) {
      log('Respuesta del servidor: $data');
      _showToast("Respuesta: ${data['message']}", ColorsJunghanns.blue);
    });

    socket.onConnectError((error) {
      log("Error de conexión: $error");

      if (!_hasShownConnectionError) {
        _hasShownConnectionError = true;

        _showToast("Error de conexión: Ocurrió un error al conectarse con el servidor.", ColorsJunghanns.red);
      }

      // Intentar reconectar en 10 segundos sin mostrar más toasts
      Future.delayed(Duration(seconds: 10), () {
        if (!socket.connected) {
          log("Reintentando conexión...");
          socket.connect();
        }
      });
    });

    socket.onError((error) {
      log("Error general del socket: $error");
    });
  }

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  String _generateToken() {
    String date = DateFormat('yyyyMMdd').format(DateTime.now());
    String dataToHash = "$date" + "_jsm";
    var bytes = utf8.encode(dataToHash);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  IO.Socket getSocket() => socket;

  bool get isConnected => _isConnected;

  void disconnect() {
    socket.disconnect();
    log("WebSocket desconectado manualmente");
  }
}
/*
class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;
  bool _hasShownConnectionError = false; // Nueva variable para evitar múltiples notificaciones

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    log("Iniciando conexión WebSocket...");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String serial = await GetMac.macAddress;
    String modelo = await DeviceInformation.deviceModel;
    if (serial.isEmpty || serial.length < 2) {
      serial = androidInfo.id ?? "";
    }

    String token = _generateToken();

    socket = IO.io('https://sandbox.junghanns.app:3002', <String, dynamic>{
      'auth': {
        'token': token,
        'user': prefs.nameUserD,
        'serial': serial,
        'model': modelo,
      },
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      log("Conectado con éxito como: ${prefs.nameUserD}");
      _isConnected = true;
      _hasShownConnectionError = false; // Reiniciar cuando se conecte exitosamente
    });

    socket.on('test_conection', (data) {
      log('Mensaje desde el servidor: $data');
      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();
      notification.logNotification();
    });

    socket.on('respuesta', (data) {
      log('Respuesta del servidor: $data');
      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();
      notification.logNotification();
    });

    socket.onConnectError((error) {
      log("Error de conexión: $error");

      if (!_hasShownConnectionError) {
        _hasShownConnectionError = true; // Marcar que ya se mostró el error

        PushNotificationModel notification = PushNotificationModel(
          title: "Error de conexión",
          message: "Ocurrió un error al intentar conectar.",
          code: "500",
        );
        notification.showNotification();
        notification.logNotification();
      }

      // Intentar reconectar en 10 segundos sin mostrar más notificaciones
      Future.delayed(Duration(seconds: 10), () {
        if (!socket.connected) {
          log("Reintentando conexión...");
          socket.connect();
        }
      });
    });

    socket.onError((error) {
      log("Error general del socket: $error");
    });
  }

  String _generateToken() {
    String date = DateFormat('yyyyMMdd').format(DateTime.now());
    String dataToHash = "$date" + "_jsm";
    var bytes = utf8.encode(dataToHash);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  IO.Socket getSocket() => socket;

  bool get isConnected => _isConnected;

  void disconnect() {
    socket.disconnect();
    log("WebSocket desconectado manualmente");
  }
}*/
