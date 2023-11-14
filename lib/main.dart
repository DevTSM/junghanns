// ignore_for_file: override_on_non_overriding_member, unnecessary_new

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  WebSocketChannel channel = IOWebSocketChannel.connect(Uri.parse('ws://192.168.1.117:3000'));
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final GlobalKey<NavigatorState> _navKey = GlobalKey();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print("======= Aqui ============= ");
    channel.stream.listen((event) {
      // Manejar las respuestas del servidor
      print('Respuesta del servidor: $event');
    },
    onDone: () {
      // Manejar la desconexión del servidor
      print('Desconectado del servidor');
    },
    onError: (error) {
      // Manejar errores de conexión
      print('Error de conexión: $error');
    });
    channel.sink.add("Hola desde flutter");
      print("Escribiendo");
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    channel.sink.close();
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
        ),
        initialRoute: '/',
        routes: getApplicationRoutes(),
      )
    );
  }
}
