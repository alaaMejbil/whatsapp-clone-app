import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationData {
  final String chatrommId;
  final String contactId;
  final String contactUserName;
  final String contactImageUrl;

  LocalNotificationData(
      {required this.chatrommId,
      required this.contactId,
      required this.contactUserName,
      required this.contactImageUrl});
}

class LocalNotificationView {
  final timeout = const Duration(seconds: 4);
  final ms = const Duration(milliseconds: 1);

  bool isShowLocalNotification = false;
  double localNotificationAnimationOpacity = 0.0;
  late ValueChanged<List<dynamic>> changeNotificationState;

  LocalNotificationData localNotificationData = LocalNotificationData(
    chatrommId: "",
    contactId: "",
    contactUserName: "",
    contactImageUrl: "",
  );

  void checkLocalNotification(Function changeNotificationState, String chatID) {
    //this.changeNotificationState = changeNotificationState;
    // onMessage
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('ChatList Got a message whilst in the foreground!');
      print('ChatList Message data: ${message.data}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final inRoomChatId = prefs.getString("inRoomChatId") ?? "";

      //   if (inRoomChatId != message.data["chatroomid"]) {
      if (message.data != null) {
        // && chatID != message.data["chatroomid"]) {
        LocalNotificationData localNotificationData = LocalNotificationData(
          chatrommId: message.data["chatroomId"],
          contactId: message.data["contactId"],
          contactImageUrl: message.data["contactUserName"],
          contactUserName: message.data["contactImageUrl"],
        );
        //this.changeNotificationState([localData, 1.0]);
        startTimeout();
      }
      // }
    });
  }

  Widget localNotificationCard(Size size) {
    return Positioned(
      top: size.height / 10,
      left: size.width / 6,
      child:
          // AnimatedOpacity(
          //   opacity: localNotificationAnimationOpacity,
          //   duration: const Duration(milliseconds: 1000),
          //   child:
          // localNotificationAnimationOpacity == 0
          //     ? Container()
          //     :
          Container(
        width: size.width / 1.5,
        child: Card(
            color: Colors.red[900],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: localNotificationData.contactImageUrl != ""
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24.0),
                              child: CachedNetworkImage(
                                imageUrl: localNotificationData.contactImageUrl,
                                placeholder: (context, url) => Container(
                                  transform:
                                      Matrix4.translationValues(0.0, 0.0, 0.0),
                                  child: Container(
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                          child:
                                              new CircularProgressIndicator())),
                                ),
                                errorWidget: (context, url, error) =>
                                    new Icon(Icons.error),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.account_circle,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          localNotificationData.contactUserName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('Here is user msg ..',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Timer startTimeout() {
    var duration = timeout;
    return Timer(duration, handleTimeout);
  }

  void handleTimeout() {
    this.changeNotificationState([null, 0.0]);
  }
}
