import 'dart:developer';
import 'package:device_info/device_info.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:mac_address/mac_address.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../util/push_notifications_provider.dart';

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
    log("🔌 Iniciando conexión WebSocket...");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String serial = await GetMac.macAddress;
    if(serial.isEmpty||serial.length<2){
      serial=androidInfo.id??"";
    }
    socket = IO.io('http://192.168.0.15:3000', <String, dynamic>{
      'auth': {
        'user': prefs.nameUserD,
        'route': prefs.idRouteD,
        'device_name': serial,
      },
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      log("✅ Conectado con éxito como: ${prefs.nameUserD}");

      _isConnected = true;
    });

    socket.on('junny_notify', (data) {
      log('📩 Mensaje desde el servidor: $data');
      NotificationService().showNotifications("Notificación", data.toString());
    });

    socket.on('respuesta', (data) {
      log('📩 Respuesta del servidor: $data');
      NotificationService().showNotifications("Respuesta", data.toString());
    });

    socket.onDisconnect((_) {
      log("❌ Desconectado del servidor");
      _isConnected = false;
      NotificationService().showNotifications("Conexión perdida", "No se pudo conectar al servidor.");
    });

    socket.onConnectError((error) {
      log("⚠️ Error de conexión: $error");
      NotificationService().showNotifications("Error de conexión", "Ocurrió un error al intentar conectar.");
    });

    // Intentar reconectar después de 10 segundos si la conexión falla
    Future.delayed(Duration(seconds: 10), () {
      if (!socket.connected) {
        log("🔄 Reintentando conexión...");
        socket.connect();
      }
    });

    socket.onConnectError((data) => log('===> Error de conexión: $data'));
  }

  IO.Socket getSocket() => socket;

  bool get isConnected => _isConnected;

  void disconnect() {
    socket.disconnect();
    log("❌ WebSocket desconectado manualmente");
  }
}
