import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //NotificationService a singleton object
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static const channelId = '123';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    log("------------------ NotificationService ---------------------");
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  final AndroidNotificationDetails _androidNotificationDetails =
      const AndroidNotificationDetails(
    'channel ID',
    'channel name',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );
  final IOSNotificationDetails _iosNotificationDetails =
      const IOSNotificationDetails(sound: 'slow_spring_board.aiff');

  // Método actualizado para generar un ID único
  Future<void> showNotifications(String title, String body) async {
    try {
      // Genera un ID único para cada notificación (timestamp)
      int notificationId = DateTime.now().millisecondsSinceEpoch % (1 << 31);  // Limita al rango de 32 bits

      await flutterLocalNotificationsPlugin.show(
        notificationId, // Usar un ID único
        title,
        body,
        NotificationDetails(
            android: _androidNotificationDetails, iOS: _iosNotificationDetails),
      );
    } catch (e) {
      log("error notificacionService=====> ${e.toString()}");
    }
  }
  /*Future<void> showNotifications(String title, String body) async {
    try{
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
          android: _androidNotificationDetails, iOS: _iosNotificationDetails),
    );
    }catch(e){
      log("error =====> ${e.toString()}");
    }
  }*/

  Future<void> scheduleNotifications() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Notification Title",
        "This is the Notification Body!",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        NotificationDetails(
            android: _androidNotificationDetails, iOS: _iosNotificationDetails),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

Future selectNotification(String? payload) async {
  //handle your logic here
}
