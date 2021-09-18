// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:notifiaction_app/screens/chat_screen.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final String? myId;
  final String? myUserName;
  final String contactName;
  final String contactImageUrl;
  final String contactId;
  final String contactStatus;
  final bool isOnline;

  // ignore: use_key_in_widget_constructors
  const UserListTile({
    required this.contactName,
    required this.contactImageUrl,
    required this.contactId,
    required this.contactStatus,
    required this.myId,
    required this.isOnline,
    required this.myUserName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              // create chatRoom Id : myId_contactId
              String chatRoomId = "";
              if (myId!.substring(0, 1).codeUnitAt(0) >
                  contactId.substring(0, 1).codeUnitAt(0)) {
                chatRoomId = '$myId\_$contactId';
              } else {
                chatRoomId = '$contactId\_$myId';
              }
              Map<String, dynamic> chatRoomInfo = {
                "chatroomId": chatRoomId,
                "users": [myId, contactId],
                "usersName": {
                  myId: myUserName,
                  contactId: contactName,
                },
                "isChatRoomEmpty": true,
                "countNewMessages": 0,
              };
              DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfo);
              // go to chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatRoomId: chatRoomId,
                    myId: myId,
                    contactUserName: contactName,
                    contactImageUrl: contactImageUrl,
                    contactId: contactId,
                  ),
                ),
              );
            },
            child: Row(
              children: <Widget>[
                Stack(
                  children: [
                    (contactImageUrl != "")
                        ? Material(
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
                              imageUrl: contactImageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
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
                    if (isOnline)
                      const Positioned(
                        bottom: 8,
                        right: -1,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: Colors.green,
                        ),
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
                      Text(
                        contactName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      // ignore: sized_box_for_whitespace
                      Container(
                        width: 300.0,
                        height: 20.0,
                        child: Text(
                          contactStatus,
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
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
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
