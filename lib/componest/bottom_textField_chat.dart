// ignore_for_file: file_names

import 'dart:convert';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:http/http.dart' as http;

import 'package:notifiaction_app/services/database.dart';
import 'package:notifiaction_app/services/local_notification_services.dart';
import 'package:notifiaction_app/services/shared_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
//import 'package:random_string/random_string.dart';

import '../constans.dart';
import '../main.dart';

class bottomTextFieldChat extends StatefulWidget {
  final String chatRoomId;

  const bottomTextFieldChat({Key? key, required this.chatRoomId})
      : super(key: key);

  @override
  _bottomTextFieldChatState createState() => _bottomTextFieldChatState();
}

class _bottomTextFieldChatState extends State<bottomTextFieldChat> {
  final _textChatControler = TextEditingController()..text = "";
  String messageId = "";
  bool isLoading = false;

  late String myId;
  late String myUserName;
  //late String myImageUrl;

  void getMyInfoFromShared() async {
    myId = (await SharedMethod().getUserId())!;
    myUserName = (await SharedMethod().getUserName())!;
    //myImageUrl = (await SharedMethod().getUserProfileUrl())!;
    setState(() {});
  }

  @override
  void initState() {
    getMyInfoFromShared();
    super.initState();
  }

  // late File _image;
  // final picker = ImagePicker();
  // String randomImageName = "";
  //
  // Future getImage(ImageSource src) async {
  //   final pikedFile = await picker.getImage(source: src, imageQuality: 20);
  //   setState(() {
  //     if (pikedFile != null) {
  //       setState(() {
  //         _image = File(pikedFile.path);
  //         if (_image != null) {
  //           setState(() {
  //             isLoading = true;
  //           });
  //           //uploadFile();
  //         }
  //       });
  //     } else {
  //       print('Mo image selected');
  //     }
  //   });
  // }

  // Future sendFileImage() async {
  //   // randomImageName = "${randomAlphaNumeric(12)}.jpg";
  //   randomImageName = "${DateTime.now()}.jpg";
  //
  //   try {
  //     final ref = FirebaseStorage.instance
  //         .ref()
  //         .child('user_images')
  //         .child(randomImageName);
  //
  //     await ref.putFile(_image);
  //
  //     final url = await ref.getDownloadURL();
  //
  //     // send to FireStore
  //     // messageId = randomAlphaNumeric(12);
  //     messageId = "${DateTime.now()}";
  //     String contactId = widget.chatRoomId.replaceAll(myId, "");
  //     contactId = contactId.replaceAll('_', "");
  //     Map<String, Object> messageInfoMap = {
  //       //'msgText': _textChatControler.text,
  //       'senderId': myId,
  //       'userName': myUserName,
  //       'reciveId': contactId,
  //       'timeStamp': DateTime.now().millisecondsSinceEpoch,
  //       'typeMessage': 'image',
  //       'imageUrl': url,
  //       'isread': false,
  //     };
  //
  //     DatabaseMethods()
  //         .sendMessage(messageId, widget.chatRoomId, messageInfoMap)
  //         .then((value) {
  //       Map<String, dynamic> lastMessageInfoMap = {
  //         'lastMessage': 'photo',
  //         'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
  //         'lastMessageSender': myId,
  //         'isChatRoomEmpty': false,
  //         'lastMessageIsRead': false,
  //       };
  //       DatabaseMethods()
  //           .updateLastMessage(widget.chatRoomId, lastMessageInfoMap);
  //
  //       DatabaseMethods().increaseCountNewMessages(widget.chatRoomId);
  //     });
  //     print('success !');
  //     //_image = null;
  //
  //     //_textChatControler.clear();
  //     //FocusScope.of(ctx).unfocus();
  //   } catch (e) {
  //     print('ERROR : $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 60,
      color: const Color(0xFF161616),
      child: Row(
        children: <Widget>[
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey,
                size: 25,
              )),
          Expanded(
            child: Container(
              // width: size.width * 0.7,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                controller: _textChatControler,
                onChanged: (val) {
                  setState(() {
                    val = _textChatControler.text;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Message ',
                  filled: true,
                  fillColor: Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              buildShowModalBottomSheet(context);
            },
            icon: const Icon(
              Icons.attachment_outlined,
              color: Colors.grey,
              size: 25,
            ),
          ),
          if (_textChatControler.text.isEmpty)
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.keyboard_voice_outlined,
                  color: Colors.grey,
                  size: 25,
                )),
          if (_textChatControler.text.isNotEmpty)
            IconButton(
                onPressed: () => _sendFunction(context),
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.grey,
                  size: 25,
                )),
        ],
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext ctx) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        context: context,
        builder: (ctx) {
          return Wrap(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            // await getImage(ImageSource.camera);
                            // sendFileImage();
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: const [
                              CircleAvatar(
                                child: Icon(Icons.camera_alt_outlined),
                              ),
                              Text('Camera'),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            // await getImage(ImageSource.gallery);
                            //
                            // sendFileImage();
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: const [
                              CircleAvatar(
                                child: Icon(Icons.panorama_sharp),
                              ),
                              Text('Gallery'),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: const [
                              CircleAvatar(
                                child: Icon(Icons.audiotrack_outlined),
                              ),
                              Text('Audio'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  int _counter = 0;

  void _sendFunction(BuildContext ctx) async {
    if (_textChatControler.text.trim().isNotEmpty) {
      // messageId = randomAlphaNumeric(12);
      messageId = "${DateTime.now()}";

      String messageText = _textChatControler.text;
      String contactId = widget.chatRoomId.replaceAll(myId, "");
      contactId = contactId.replaceAll('_', "");
      Map<String, dynamic> messageInfoMap = {
        'msgText': _textChatControler.text,
        'senderId': myId,
        'reciveId': contactId,
        'userName': myUserName,
        'timeStamp': DateTime.now().millisecondsSinceEpoch,
        'typeMessage': 'text',
        'isread': false,
      };
      DatabaseMethods()
          .sendMessage(messageId, widget.chatRoomId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': messageText,
          'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          'lastMessageSender': myId,
          'isChatRoomEmpty': false,
          'lastMessageIsRead': false,
        };
        DatabaseMethods()
            .updateLastMessage(widget.chatRoomId, lastMessageInfoMap);
        DatabaseMethods().increaseCountNewMessages(widget.chatRoomId);
      });

      _textChatControler.clear();
      FocusScope.of(ctx).unfocus();

      // sendNotificationMessageToPeerUser(
      //     'tmlVzlwf0sSjmypeHWbtn3u4gYC2_EzHIPwE9f9gIjsoxxV1TPkbblY43',
      //     'tmlVzlwf0sSjmypeHWbtn3u4gYC2',
      //     'bedoo',
      //     "",
      //     "HHHhHHHhh");

      //showNotification(messageText, "ALAA");
    }
  }

  Future<void> sendNotificationMessageToPeerUser(
      String chatroomId,
      String contatctUserId,
      String myName,
      String contactImageUrl,
      String messageContent) async {
    // FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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
              'body': 'text',
              'title': '$myName',
              // 'badge':'$unReadMSGCount',//'$unReadMSGCount'
              "sound": "default",
              //"image": myImageUrl
            },
            // 'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'chatroomId': chatroomId,
              'contatctUserId': contatctUserId,
              'userName': '$myName',
              'contactImageUrl': contactImageUrl,
              'messageContent': messageContent,
            },
            'to': contatctUserId,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
