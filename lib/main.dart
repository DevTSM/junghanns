// ignore_for_file: override_on_non_overriding_member, unnecessary_new

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/routes/routes.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// @pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     var socket = IO.io('https://pue-sur.junghanns.app:3000', <String, dynamic>{
//     'transports': ['websocket'],
//     'autoConnect': true,
//   });
//   try{
//     socket.connect();
//     // Escucha eventos del servidor
//     socket.on('junny_notify', (data) {
//     log('Mensaje desde el servidor: $data');
//     prefs.urlBase=urlBaseManuality;
//     prefs.labelCedis=data.toString();
//   });
//   log("Conectado ${socket.acks.toString()}");
//   socket.emit('catch_mobile', 'Hola, servidor!');
//     }catch(e){
//       log("ERORR: ${e.toString()}");
//     }
//   return Future.value(true);
//   });
// }

@pragma('vm:entry-point')
Future<void> messageHandler(RemoteMessage message) async {
  print ("Notification was received on background");
  NotificationModel notification=NotificationModel.fromEvent(message);
  handler.insertNotification(notification.getMap);
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
  //   callbackDispatcher, // The top level function, aka callbackDispatcher
  //   isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  // );
  //Workmanager().registerOneOffTask("task-identifier", "simpleTask");

  var socket = IO.io('https://pue-sur.junghanns.app:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });
  try{
    socket.connect();
    // Escucha eventos del servidor
    socket.on('junny_notify', (data) {
    log('Mensaje desde el servidor: $data');
    prefs.urlBase=urlBaseManuality;
    prefs.labelCedis=data.toString();
  });
  log("Conectado ${socket.acks.toString()}");
  socket.emit('catch_mobile', 'Hola, servidor!');
  }catch(e){
    log(e.toString());
  }
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
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: JunnyColor.bluefe
          )
        ),
        initialRoute: '/',
        routes: getApplicationRoutes(),
      )
    );
  }
}
