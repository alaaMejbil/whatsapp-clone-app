import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:notifiaction_app/componest/chatRoom_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constans.dart';
import '../main.dart';
import 'all_members.dart';

class ChatRoomsScreen extends StatefulWidget {
  final String myId;

  const ChatRoomsScreen({Key? key, required this.myId}) : super(key: key);

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  late bool isCollectionExist;
  late bool isContactUserOnline;
  String? myId = "";

  @override
  void initState() {
    // ignore: avoid_print
    print('my ID in chatroom is ${widget.myId}');
    myId = widget.myId;
    // getMyInfoFromShared();
    () async {}();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          listenToNewChatrooms(),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> listenToNewChatrooms() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatrooms')
          .where('users', arrayContains: widget.myId)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final myChatrooms = snapshot.data!.docs;
          List<Widget> chatrooms_List = [];
          for (var chatroom in myChatrooms) {
            if (!chatroom['isChatRoomEmpty']) {
              print(chatroom['chatroomId']);
              print(widget.myId);
              String contactId =
                  chatroom['chatroomId'].replaceAll(widget.myId, "");
              contactId = contactId.replaceAll('_', "");
              chatrooms_List.add(
                ChatRoomListTile(
                  myId: widget.myId,
                  contactUserId: contactId,
                  chatroomId: chatroom.id,
                  contactUserName: chatroom['usersName'][contactId],
                  lastMessage: chatroom['lastMessage'],
                  lastMessageIsRead: chatroom['lastMessageIsRead'],
                  lastMessageTime: chatroom['lastMessageTimeStamp'],
                  countNewMessages: chatroom['countNewMessages'],
                  isLastMessageSendedByMe:
                      chatroom['lastMessageSender'] == widget.myId,
                ),
              );
            }
          }
          return Expanded(
            child: ListView(
              children: chatrooms_List,
            ),
          );
        } else {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Loading....',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 18),
              ),
            ),
          );
        }
      },
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: primary,
      child: const Icon(
        Icons.message,
        color: Colors.white,
        size: 26,
      ),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AllMembersScreen()));
      },
    );
  }
}
