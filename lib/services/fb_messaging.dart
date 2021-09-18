import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constans.dart';

class NotificationController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationController get instance => NotificationController();

  Future takeFCMTokenWhenAppLaunch() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        saveUerTokenToSharedPreference();
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        saveUerTokenToSharedPreference();
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      // onMessageOpenedApp
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUerTokenToSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _firebaseMessaging
        .getToken(vapidKey: firebaseCloudvapidKey)
        .then((val) async {
      print('Token: ' + val!);
      prefs.setString('FCMToken', val);
    });
  }

  Future<void> updateTokenToServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging
        .getToken(vapidKey: firebaseCloudvapidKey)
        .then((val) async {
      // ignore: avoid_print
      print('Token: ' + val!);
      prefs.setString('FCMToken', val);
      Object? userID = prefs.get('userId');
      // if (userID != null) {
      //   FirebaseAuth.instance.authStateChanges().listen((User user) {
      //     if (user != null) {
      //       FBCloudStore.instanace.updateUserToken(userID, val);
      //     }
      //   });
      // }
    });
  }

  Future initLocalNotification() async {
    if (Platform.isIOS) {
      // set iOS Local notification.
      var initializationSettingsAndroid =
          AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    } else {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);
    }
  }

  Future _onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {}

  Future _selectNotification(String? payload) async {}

  Future<void> sendNotificationMessageToPeerUser(unReadMSGCount, messageType,
      textFromTextField, myName, chatID, peerUserToken, myImageUrl) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$firebaseCloudserverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': messageType == 'text' ? '$textFromTextField' : '(Photo)',
              'title': '$myName',
              'badge': '$unReadMSGCount', //'$unReadMSGCount'
              "sound": "default",
              "image": myImageUrl
            },
            // 'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'easyapproach',
              'id': '1',
              'status': 'done',
              'chatroomid': chatID,
              'userImage': myImageUrl,
              'userName': '$myName',
              'message':
                  messageType == 'text' ? '$textFromTextField' : '(Photo)',
            },
            'to': peerUserToken,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
