// ignore_for_file: override_on_non_overriding_member, unnecessary_new

import 'dart:async';
import 'dart:developer';
import 'dart:io';

//import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/pages/socket/socket_service.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/chat_provider.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/routes/routes.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/util/navigator.dart';
import 'package:junghanns/util/push_notifications_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
Future<void> messageHandler(RemoteMessage message) async {
  print ("Notification was received on background");
  NotificationModel notification = NotificationModel.fromEvent(message);
  handler.insertNotification(notification.getMap);
}
@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    //initWebSocket();
    print("Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}


/*void initWebSocket() {
  var url = '${prefs.urlBase}:3002';
  //var socket = IO.io('https://sandbox.junghanns.app:3002',
  var socket = IO.io('https://sandbox.junghanns.app:3002',
    <String, dynamic>{
      'auth': {"token":"123456789"},
      'transports': ['websocket'],
      'autoConnect': true,
    }
  );
  try{
    if(true){
    socket.connect();
    
    prefs.conectado = true;
    }else{
      log("con proceso =======================>");
    }
    socket.onConnect((data){
      socket.emit('catch_mobile', 'Hola, servidor! Junny');
      socket.emit('primerDato', 'Hola, servidor! Junny');
      log("################# Conectado");
      log("################# Conectado $data");
    });
    // Escucha eventos del servidor
    socket.on('junny_notify', (data)async {
      log('Mensaje desde el servidor: $data');
      NotificationService _notificationService = NotificationService();
      _notificationService.showNotifications("Notify", data.toString());
    });
    socket.on('respuesta', (data)async {
      log('Mensaje desde el servidor: $data');
      NotificationService _notificationService = NotificationService();
      _notificationService.showNotifications("Notify", data.toString());
    });

    // Escuchar el evento de desconexión
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
    Future.delayed(Duration(seconds: 10),(){
      if(!socket.connected){
        print("Terminando socket");
        socket.close();
      }
    });
    socket.onConnectError((data)=> log('===> Error de conexion $data'));
  }catch(e){
    log("ERORR: ${e.toString()}");
  }
}*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage (messageHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
  });
  await prefs.initPrefs();
  HttpOverrides.global = new MyHttpOverrides();
  await handler.initializeDB();
  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: false 
  // );
  // Workmanager().registerOneOffTask("task-identifier", "notification");
  //initWebSocket();
  // Inicia el WebSocket global
  //SocketService();

  runApp(const JunnyApp());
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
        (X509Certificate cert, String host, int port) => true;
  }
}

class JunnyApp extends StatefulWidget {
  const JunnyApp({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _JunnyAppState();
}

class _JunnyAppState extends State<JunnyApp> with WidgetsBindingObserver{
  
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final GlobalKey<NavigatorState> _navKey = GlobalKey();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Timer(const Duration(seconds: 2), () async { 
        log("####################");
        Provider.of<ProviderJunghanns>(navigatorKey.currentContext!,listen:false)
          .requestAllPermissionsResumed();
      });
    }
    if(state == AppLifecycleState.hidden){
      prefs.isRequest = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ProviderJunghanns()),
          //ChangeNotifierProvider(create: (context) => ChatProvider()), // Aquí agregas el ChatProvider
        ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('es'), // Spanish, no country code
        ],
        title: 'JUNGHANNS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          dialogBackgroundColor: JunnyColor.white,
          cardColor: JunnyColor.white,
          colorScheme: ColorScheme.fromSwatch(
            cardColor: JunnyColor.white,
            backgroundColor: JunnyColor.bluefe,
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
            ),
            backgroundColor: JunnyColor.white
          )
        ),
        initialRoute: '/',
        routes: getApplicationRoutes(),
      )
    );
  }
}
