import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifiaction_app/screens/chat_screen.dart';
import 'package:notifiaction_app/screens/tabs_screen.dart';
import 'package:notifiaction_app/services/auth_screen.dart';
import 'package:notifiaction_app/services/local_notification_services.dart';
import 'package:notifiaction_app/services/local_notification_view.dart';
import 'package:notifiaction_app/services/shared_method.dart';

import 'package:android_alarm_manager/android_alarm_manager.dart';

// always will execution
Future<void> backgroundHandler(RemoteMessage message) async {
  print('here is backgroundHandler :');
  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  //Step 1
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? myId = "";
  String? myUserName = "";
  String? myImageUrl;

  Future getMyInfoFromShared() async {
    myId = await SharedMethod().getUserId();
    myUserName = await SharedMethod().getUserName();
    // myImageUrl = (await SharedMethod().getUserProfileUrl())!;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    LocalNotificationService.initialize(context);

    //Step 2
    // this stream only work when :
    // the app will be in the background and app CLOSED and user taps on the notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print('here is getInitialMessage :');
      if (message != null) {
        final routeFromMessage = message.data["route"];
        //Navigator.push(context, MaterialPageRoute(builder: (context) => Home));
        print(routeFromMessage);
      }
    });

    //Step 3
    // this stream only work when the app will be in the foreground
    // when app will be in background this message will never get called
    FirebaseMessaging.onMessage.listen((message) {
      print('here is onMessage :');
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
      }
      LocalNotificationService.display(message);
    });

    //Step 4
    // this stream only work when :
    // the app will be in the background and app opened and user taps on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('here is onMessageOpenedApp start listening ......');

      print(message.data.toString());

      // get data coming from notification message
      final String chatroomIdFromNotification = message.data["chatroomId"];
      final String contatctUserId = message.data["contactId"];
      final String contactUserName = message.data["contactUserName"];
      final String contactImageUrl = message.data["contactImageUrl"];

      print('the sender name is : $contactUserName');

      // LocalNotificationData localNotificationData = LocalNotificationData(
      //   chatrommId: message.data["chatroomId"],
      //   contactId: message.data["contactId"],
      //   contactImageUrl: message.data["contactUserName"],
      //   contactUserName: message.data["contactImageUrl"],
      // );

      // go to chatscreen when tap the notification msg
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            myId: myId,
            chatRoomId: chatroomIdFromNotification,
            contactUserName: contactUserName,
            contactId: contatctUserId,
            contactImageUrl: contactImageUrl,
          ),
        ),
      );
    });

    () async {
      await getMyInfoFromShared();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.providerData.length == 1) {
              print('snapsht data is ${snapshot.data!.uid}');
              print('if i have Token go to TabScreen');
              return TabsScreen(
                myId: snapshot.data!.uid,
                myName: myUserName,
                tabSelected: 0,
              );
            } else {
              return AuthScreen();
            }
          }

          return AuthScreen();
        },
      ),
    );
  }
}
