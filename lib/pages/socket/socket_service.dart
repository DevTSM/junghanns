import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import '../../models/notification/push_notification_model.dart';
class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;
  bool _hasShownConnectionError = false;

  factory SocketService() => _instance;

  SocketService._internal();

  Future<void> connectIfLoggedIn() async {
    if (prefs.nameUserD.isNotEmpty) {
      await _initWebSocket();
    } else {
      log("No se conectará al WebSocket: usuario no logueado");
    }
  }

  Future<void> _initWebSocket() async {
    log("Iniciando conexión WebSocket...");

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    String serial = androidInfo.id ?? "";
    String modelo = androidInfo.model ?? "";
    String marca = androidInfo.manufacturer ?? "";

    String token = _generateToken();
    String sistemaop = obtenerSistemaOperativo();

    final String urlBase = prefs.urlBase.replaceAll(RegExp(r'\/$'), '');
    final String puerto = urlBase.contains('sandbox') ? '4102' : '4002';
    final String urlCompleta = '$urlBase:$puerto';

    print('Conectando a: $urlCompleta');


    socket = IO.io(
      urlCompleta,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({
        'token': token,
        'user': prefs.nameUserD,
        'serial': serial,
        'model': modelo,
        'marca': marca,
        'so': sistemaop,
      })
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      log("Conectado con éxito como: ${prefs.nameUserD}");
      _showToast("Conexión exitosa al servidor de notificaciones", ColorsJunghanns.green);
      _isConnected = true;
      _hasShownConnectionError = false;
    });

    socket.on('connect', (_) {
      print('Conexión exitosa al socket con ID: ${socket.id}');
      log('CLIENTE: Conexión exitosa al socket con ID: ${socket.id}');
    });

    socket.on('receiveNotification', (data) {
      print("Notificación recibida: $data");
      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();
      notification.logNotification();

      socket.emitWithAck('confirmNotification', {
        'id': data['id'] ?? 'no-id',
        'id_emisor': data['id_emisor'] ?? 'no-id_emisor',
        'id_usuario': data['id_usuario'] ?? 'no-id_usuario',
      }, ack: (response) {
        print('Servidor confirmó recepción: $response');
      });

      //notificationMessage = data.toString();
    });

    socket.on('acceptProcess', (data) {
      print("✅ Proceso aceptado: $data");
      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();
      notification.logNotification();

      socket.emitWithAck('confirmAcceptProcess', {
        'id': data['id'] ?? 'no-id',
        'id_emisor': data['id_emisor'] ?? 'no-id_emisor',
        'id_usuario': data['id_usuario'] ?? 'no-id_usuario',
      }, ack: (response) {
        print('Servidor confirmó aceptación del proceso: $response');
      });

      // processMessage = data.toString();
    });

    socket.on('connect_error', (error) {
      print('Error al conectar al socket: ${error.toString()}');
      log('Error al conectar al socket: ${error.toString()} <br>');
    });

    socket.on('disconnect', (reason) {
      log('CLIENTE: El socket se desconectó: $reason');
    });

    socket.on('respuesta', (data) {
      log('Respuesta del servidor: $data');
      _showToast("Respuesta: ${data['message']}", ColorsJunghanns.blue);
    });

    socket.onConnectError((error) {
      log("Error de conexión: $error");

      if (!_hasShownConnectionError) {
        _hasShownConnectionError = true;
        _showToast("Error de conexión: Ocurrió un error al conectarse con el servidor notificaciones.", ColorsJunghanns.red);
      }

      // Intentar reconectar en 10 segundos sin mostrar más toasts
      Future.delayed(Duration(seconds: 10), () {
        if (!socket.connected) {
          log("Reintentando conexión...");
          socket.connect();
        }
      });
    });
  }

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }
  String obtenerSistemaOperativo() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Desconocido';
    }
  }

  String _generateToken() {
    String date = DateFormat('yyyyMMdd').format(DateTime.now());
    String dataToHash = "$date" + "_jusoft";
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