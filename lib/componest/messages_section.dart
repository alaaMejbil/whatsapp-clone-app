// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bubble_image.dart';
import 'bubble_message.dart';

class Messages extends StatefulWidget {
  final String myId;
  final String chatRoomId;
  final String contactId;

  const Messages(
      {required this.chatRoomId, required this.contactId, required this.myId});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(widget.chatRoomId)
            .collection('messages')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          List<Widget> messages = [];
          for (var message in docs) {
            String msgType = message['typeMessage'];
            int msgTime = message['timeStamp'];
            bool msgIsRead = message['isread'];
            String? msgText;
            String imgUrl = "";
            if (message['reciveId'] == widget.myId) {
              // if reciver take msg
              DatabaseMethods()
                  .makeThisMessageRead(widget.chatRoomId, message.id);
              DatabaseMethods().makeLastMessageRead(widget.chatRoomId);
            }
            if (msgType == 'text') {
              msgText = message['msgText'];
            } else {
              imgUrl = message['imageUrl'];
            }

            String senderId = message['senderId'];
            String userName = message['userName'];

            if (msgType == 'text') {
              messages.add(
                BubbleMessage(
                  userName: userName,
                  msgText: msgText,
                  msgTime: msgTime,
                  isMsgRead: msgIsRead,
                  isMe: senderId == currentUser!.uid,
                ),
              );
            }

            if (msgType == 'image')
              messages.add(
                BubbleImage(
                    userName: userName,
                    imgUrl: imgUrl,
                    msgTime: msgTime,
                    isMsgRead: msgIsRead,
                    isMe: senderId == currentUser!.uid),
              );
          }

          return snapshot.hasData
              ? ListView(
                  reverse: true,
                  children: messages,
                )
              : const CircularProgressIndicator();
        },
      ),
    );
  }
}
