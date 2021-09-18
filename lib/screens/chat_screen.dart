import 'package:cached_network_image/cached_network_image.dart';
import 'package:notifiaction_app/componest/bottom_textField_chat.dart';
import 'package:notifiaction_app/componest/messages_section.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../constans.dart';

class ChatScreen extends StatefulWidget {
  final String? myId;
  final String contactId;
  final String contactUserName;
  final String contactImageUrl;
  final String chatRoomId;

  // ignore: use_key_in_widget_constructors
  const ChatScreen({
    required this.contactUserName,
    required this.contactImageUrl,
    required this.chatRoomId,
    required this.contactId,
    required this.myId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late int lastSeen;

  @override
  void initState() {
    DatabaseMethods()
        .changeInRoomValueTo(widget.myId!, widget.chatRoomId, true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: false,
        //automaticallyImplyLeading: false,
        leadingWidth: 30,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: primary, size: 25.0),
            onPressed: () async {
              // DatabaseMethods()
              //     .changeInRoomValueTo(widget.myId, widget.chatRoomId, false);
              Navigator.pop(context);
            }),
        title: Row(
          children: <Widget>[
            (widget.contactImageUrl != "")
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('userId', isEqualTo: widget.contactId)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        final DocumentSnapshot myDoc = snapshot.data!.docs[0];
                        String imageUrl = myDoc['userImageUrl'];
                        return Material(
                          borderRadius: BorderRadius.circular(150),
                          clipBehavior: Clip.hardEdge,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                              width: 55,
                              height: 55,
                              padding: const EdgeInsets.all(20),
                            ),
                            fadeInDuration: const Duration(milliseconds: 0),
                            fadeOutDuration: const Duration(milliseconds: 0),
                            imageUrl: imageUrl,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: 55,
                            height: 55,
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
                  )
                : CircleAvatar(
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.grey.shade600,
                      size: 55,
                    ),
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.7),
                  ),
            const SizedBox(
              width: 13.0,
            ),
            Expanded(
              // ignore: avoid_unnecessary_containers
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contactUserName,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('userId', isEqualTo: widget.contactId)
                          .snapshots(),
                      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Conecting...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          );
                        }
                        bool isOnline = snapshot.data!.docs[0]['isOnline'];
                        lastSeen = snapshot.data!.docs[0]['lastSeen'];

                        return isOnline
                            ? Text(
                                'online',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              )
                            : AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    ' last seen ${DateFormat('kk:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          lastSeen),
                                    )}',
                                    textStyle: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                    speed: const Duration(milliseconds: 130),
                                  ),
                                ],
                                totalRepeatCount: 5,
                                pause: const Duration(milliseconds: 1000),
                                displayFullTextOnTap: true,
                                stopPauseOnTap: true,
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.videocam,
                color: primary,
                size: 25.0,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.phone,
                color: primary,
                size: 25.0,
              ),
              onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/bg_chat.jpg"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Messages(
              myId: widget.myId!,
              chatRoomId: widget.chatRoomId,
              contactId: widget.contactId,
            ),
            bottomTextFieldChat(
              chatRoomId: widget.chatRoomId,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> _buildChatPopupMenuButton() {
    return PopupMenuButton(
      icon: const Icon(Icons.menu),
      itemBuilder: (_) {
        return <PopupMenuItem>[
          PopupMenuItem(
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                const SizedBox(
                  width: 15,
                ),
                const Text('Log Out'),
              ],
            ),
            value: 'logout',
          ),
        ];
      },
      onSelected: (val) async {
        if (val == 'logout') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          FirebaseAuth.instance.signOut();
        }
      },
    );
  }
}
