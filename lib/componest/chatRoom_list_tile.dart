// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifiaction_app/constans.dart';
import 'package:notifiaction_app/screens/chat_screen.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoomListTile extends StatefulWidget {
  final String? myId;
  final contactUserId;
  final String chatroomId;
  final String contactUserName;
  final String lastMessage;
  final bool lastMessageIsRead;
  final int lastMessageTime;
  final int countNewMessages;
  final bool isLastMessageSendedByMe;

  const ChatRoomListTile({
    @required this.contactUserId,
    required this.chatroomId,
    required this.lastMessage,
    required this.isLastMessageSendedByMe,
    required this.lastMessageTime,
    required this.lastMessageIsRead,
    required this.myId,
    required this.countNewMessages,
    required this.contactUserName,
  });

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String contactName = "";
  String contactImageUrl = "";

  //bool onlineStatus = false;

  getuserInfoById(String userId) async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserDocumentById(userId);
    contactName = "${querySnapshot.docs[0]["userName"]}";
    contactImageUrl = "${querySnapshot.docs[0]["userImageUrl"]}";
    setState(() {});
  }

  int _counter = 0;
  void showNotification({required String senderName, required String msgText}) {
    // setState(() {
    //   _counter++;
    // });
    final FlutterLocalNotificationsPlugin _notificationsPlugin =
        FlutterLocalNotificationsPlugin();
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
        0,
        senderName,
        msgText,
        notificationDetails,
        //payload: message.data['route'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getuserInfoById(widget.contactUserId);
    print(
        'New message **********************************************************************');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = "";
    return InkWell(
      onTap: () async {
        if (!widget.isLastMessageSendedByMe) {
          DatabaseMethods().makeCountNewMessagesZero(widget.chatroomId);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              myId: widget.myId,
              chatRoomId: widget.chatroomId,
              contactUserName: contactName,
              contactId: widget.contactUserId,
              contactImageUrl: contactImageUrl,
            ),
          ),
        );
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: <Widget>[
                Stack(
                  children: [
                    // contactImageUrl != ""
                    //     ?
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('userId', isEqualTo: widget.contactUserId)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final DocumentSnapshot myDoc = snapshot.data!.docs[0];
                          imageUrl = myDoc['userImageUrl'];
                          return Material(
                            borderRadius: BorderRadius.circular(150),
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                                width: 70,
                                height: 70,
                                padding: const EdgeInsets.all(20),
                              ),
                              fadeInDuration: const Duration(milliseconds: 0),
                              fadeOutDuration: const Duration(milliseconds: 0),
                              imageUrl: imageUrl,
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                child: Icon(
                                  Icons.account_circle,
                                  color: Colors.grey.shade600,
                                  size: 70,
                                ),
                                radius: 20,
                                backgroundColor: Colors.white.withOpacity(0.7),
                              ),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return CircleAvatar(
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.grey.shade600,
                              size: 65,
                            ),
                            radius: 32,
                            backgroundColor: Colors.white.withOpacity(0.7),
                          );
                        }
                      },
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('userId', isEqualTo: widget.contactUserId)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          final DocumentSnapshot myDoc = snapshot.data!.docs[0];
                          bool isOnline = myDoc['isOnline'];
                          return isOnline
                              ? const Positioned(
                                  bottom: 8,
                                  right: -1,
                                  child: CircleAvatar(
                                    radius: 7,
                                    backgroundColor: Colors.green,
                                  ),
                                )
                              : Container();
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.contactUserName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('kk:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.lastMessageTime)),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          if (widget.isLastMessageSendedByMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check,
                                color: widget.lastMessageIsRead
                                    ? primary
                                    : Colors.white.withOpacity(0.5),
                                size: 25,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              widget.lastMessage,
                              style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.white.withOpacity(0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // if iam reciver and iam not in chatroom and i am not read the new msg
                          if (!widget.isLastMessageSendedByMe &&
                              widget.lastMessageIsRead == false &&
                              widget.countNewMessages > 0)
                            Builder(builder: (context) {
                              showNotification(
                                  senderName: "Alaa",
                                  msgText: "hello word !!!");
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CircleAvatar(
                                  backgroundColor: primary,
                                  radius: 12,
                                  child:
                                      Text(widget.countNewMessages.toString()),
                                ),
                              );
                            }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 85.0),
            child: Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
