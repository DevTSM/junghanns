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
        AndroidInitializationSettings('@mipmap/ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await selectNotification(response.payload);
      },
    );

  }

  final AndroidNotificationDetails _androidNotificationDetailsWithBigImage =
  const AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: 'channel_description',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_notification',
    largeIcon: DrawableResourceAndroidBitmap('launcher_icon'),
    styleInformation: DefaultStyleInformation(true, true),

  );

  final DarwinNotificationDetails _iosNotificationDetails =
  const DarwinNotificationDetails(sound: 'slow_spring_board.aiff');


  Future<void> showNotifications(String title, String body) async {
    try {
      int notificationId = DateTime.now().millisecondsSinceEpoch % (1 << 31);

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: _androidNotificationDetailsWithBigImage,
          iOS: _iosNotificationDetails,
        ),
      );
    } catch (e) {
      log("error notificacionService=====> ${e.toString()}");
    }
  }

  Future<void> scheduleNotifications() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Notification Title",
        "This is the Notification Body!",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        NotificationDetails(
            android: _androidNotificationDetailsWithBigImage, iOS: _iosNotificationDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
