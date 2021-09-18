import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screen1.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      //when tap local notification
      if (payload != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Screen1()));
      }
    });
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "easyapproach", //id
          "easyapproach channel", //title
          "this is our channel", //description
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
          //largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
        ),
      );

      _notificationsPlugin.show(
        message.notification.hashCode,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['route'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
