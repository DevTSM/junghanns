// ignore_for_file: override_on_non_overriding_member, unnecessary_new

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/pages/socket/socket_service.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/routes/routes.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/util/navigator.dart';
import 'package:provider/provider.dart';
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

Future<void> main() async {
  ///Mantener aplicación en segundo plano
  WidgetsFlutterBinding.ensureInitialized();

  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "JUNGHANNS en segundo plano",
    notificationText: "Conexión activa",
    notificationImportance: AndroidNotificationImportance.High,
    enableWifiLock: true,
  );

  try {
    final backgroundInitialized = await FlutterBackground.initialize(androidConfig: androidConfig);
    if (backgroundInitialized) {
      await FlutterBackground.enableBackgroundExecution();
    } else {
      print("flutter_background no pudo inicializarse.");
    }
  } catch (e) {
    print("Error al inicializar flutter_background: $e");
  }

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
  // Inicia el WebSocket global
  SocketService().connectIfLoggedIn();

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
          Locale('en', ''),
          Locale('es'),
        ],
        title: 'JUNGHANNS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: JunnyColor.bluefe,
          cardColor: JunnyColor.white,
          colorScheme: const ColorScheme.light(
            primary: JunnyColor.bluefe,
            background: JunnyColor.bluefe,
          ),
          dialogBackgroundColor: JunnyColor.white,
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: JunnyColor.white,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: ColorsJunghanns.blueJ,
            selectionColor: ColorsJunghanns.blueJ,
            selectionHandleColor: ColorsJunghanns.blueJ,
          ),
        ),

        initialRoute: '/',
        routes: getApplicationRoutes(),
      )
    );
  }
}
