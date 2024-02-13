// ignore_for_file: override_on_non_overriding_member, unnecessary_new

import 'dart:async';
import 'dart:developer';
import 'dart:io';

//import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/routes/routes.dart';
import 'package:junghanns/styles/color.dart';
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
    initWebSocket();
    print("Native called background task: $task"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}


void initWebSocket() {
  var socket = IO.io('https://sandbox.junghanns.app:3002', 
    <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    }
  );
  try{
    socket.connect();
    // Escucha eventos del servidor
    socket.on('junny_notify', (data) 
      async {
        log('Mensaje desde el servidor: $data');
        NotificationService _notificationService = NotificationService();
        _notificationService.showNotifications(
          "Notify", data.toString());
      }
    );
    log("Conectado ${socket.acks.toString()}");
    socket.emit('catch_mobile', 'Hola, servidor!');
  }catch(e){
    log("ERORR: ${e.toString()}");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  initWebSocket();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ProviderJunghanns(),
      child: MaterialApp(
        scaffoldMessengerKey: _scaffoldKey,
        navigatorKey: _navKey,
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
