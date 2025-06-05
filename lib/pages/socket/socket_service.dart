import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import '../../models/notification/push_notification_model.dart';
import '../../util/navigator.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool _isConnected = false;
  bool _hasShownConnectionError = false;
  final Set<String> confirmedNotificationIds = {};
  String processMessage = '';

  factory SocketService() => _instance;

  SocketService._internal();

  Future<void> connectIfLoggedIn([BuildContext? context]) async {
    if (_isConnected) {
      log("Ya hay una conexión activa, no se reconectará.");
      return;
    }

    if (prefs.nameUserD.trim().isNotEmpty) {
      await _initWebSocket(context);
    } else {
      log("No se conectará al WebSocket: usuario no logueado");
    }
  }
  Future<void> _initWebSocket([BuildContext? context]) async {
    final user = prefs.nameUserD.trim();
    if (user.isEmpty) {
      log("Abortando conexión WebSocket: usuario vacío");
      return;
    }

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
          .enableReconnection()
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

    // IMPORTANTE: quitar cualquier listener duplicado
    socket.off('receiveNotification');
    socket.off('confirmNotification');
    socket.off('connect');
    socket.off('connect_error');
    socket.off('disconnect');
    socket.off('respuesta');

    socket.connect();

    socket.onConnect((_) {
      final horaConexion = DateFormat('HH:mm:ss').format(DateTime.now());
      log("Conectado con éxito como: ${prefs.nameUserD}, Hora de conexión${horaConexion}");
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

      final String id = data['id'] ?? 'no-id';

      if (confirmedNotificationIds.contains(id)) {
        print('Notificación $id ya confirmada, no se vuelve a confirmar.');
        return;
      }

      PushNotificationModel notification = PushNotificationModel.fromJson(data);
      notification.showNotification();

      socket.emitWithAck('confirmNotification', {
        'id': id,
        'id_emisor': data['id_emisor'] ?? 'no-id_emisor',
        'id_usuario': data['id_usuario'] ?? 'no-id_usuario',
      }, ack: (response) {
        print('Servidor confirmó recepción: $response');
        confirmedNotificationIds.add(id);
      });
    });

    socket.on('confirmProcess', (data) {
      print("Proceso aceptado: $data");
      final processProvider = Provider.of<ProviderJunghanns>(navigatorKey.currentContext!!, listen: false);

      final type = data['tipo'] ?? '';
      final status = data['estatus'] ?? '';
      final folio = data['folio']?.toString();

      processProvider.updateProcess(type, status, folio);

      socket.emitWithAck('confirmAcceptProcess', {
        'id': data['id'] ?? 'no-id',
        'id_emisor': data['id_emisor'] ?? 'no-id_emisor',
        'id_proceso': data['id'] ?? 'no-id_proceso',
        'tipo': data['tipo'] ?? 'no-tipo',
        'id_usuario': data['id_usuario'] ?? 'no-id_usuario',
      }, ack: (response) {
        print('Servidor confirmó aceptación del proceso: $response');
      });

      processMessage = data.toString();
    });

    socket.on('connect_error', (error) {
      print('Error al conectar al socket: ${error.toString()}');
      log('Error al conectar al socket: ${error.toString()} <br>');
    });

    socket.on('disconnect', (reason) {
      log('CLIENTE: El socket se desconectó: $reason');
      final horaDesconexion = DateFormat('HH:mm:ss').format(DateTime.now());
      log('CLIENTE: El socket se desconectó a las $horaDesconexion. Motivo: $reason');
      _isConnected = false;

      Future.delayed(Duration(seconds: 10), () {
        if (!socket.connected) {
          log("Reintentando conexión tras desconexión...");
          socket.connect();
        }
      });
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

      Future.delayed(Duration(seconds: 10), () {
        if (!socket.connected) {
          log("Reintentando conexión...");
          socket.connect();
        }
      });
    });
  }

  void disconnect() {
    if (_isConnected) {
      socket.off('receiveNotification');
      socket.off('confirmNotification');
      socket.off('connect_error');
      socket.off('disconnect');
      socket.off('respuesta');
      socket.off('connect');
      socket.disconnect();
      _isConnected = false;
      log("WebSocket desconectado manualmente");
    }
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
    String plataforma = kIsWeb
        ? 'Web'
        : Platform.operatingSystem;

    switch (plataforma) {
      case 'Web':
        return 'Web';
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'windows':
        return 'Windows';
      case 'macos':
        return 'macOS';
      case 'linux':
        return 'Linux';
      default:
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
}