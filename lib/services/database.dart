import 'package:notifiaction_app/services/shared_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  Future addUserInfoToDB(
      String userId, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(userInfoMap);
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfo) async {
    // check if this chatRoom created or not
    final snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      // chatroom already exists dont make anythings
      print('chatroom already exists dont make anythings');
      return true;
    } else {
      // chatroom does not exists : --> create chatRoom Now.
      print(' chatroom does not exists');
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfo);
    }
  }

  Future sendMessage(String messageId, String chatRoomId,
      Map<String, dynamic> messageInfoMap) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future updateLastMessage(
      String chatRoomId, Map<String, dynamic> lastMessageInfo) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .update(lastMessageInfo);
  }

  Future<Stream<QuerySnapshot>> getChatroomMessages(
      String chatRoomId, Map messageInfoMap) async {
    return await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserDocumentById(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("userId", isEqualTo: userId)
        .get();
  }

  checkIfContactInRoom(String myId, String contactId, String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .collection('myChatRooms')
        .doc(chatRoomId)
        .get();
  }

  Future<Stream<QuerySnapshot>> getMyChatrooms() async {
    String? myUserId = await SharedMethod().getUserId();
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .where('users', arrayContains: myUserId)
        .snapshots();
  }

  // to know if contant is open chatroom and waiting me to send msg
  changeInRoomValueTo(String myId, String chatRoomId, bool value) async {
    // create  inRoom = true or false
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .collection('myChatRooms')
        .doc(chatRoomId)
        .set({
      'inRoom': value, // true or false
    });
  }

  Future makeThisMessageRead(String chatRoomId, String msgID) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(msgID)
        .update({
      'isread': true,
    });
  }

  Future makeLastMessageRead(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .update({
      'lastMessageIsRead': true,
    });
  }

  increaseCountNewMessages(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .get()
        .then((value) {
      int count = value.data()!['countNewMessages'];
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .update({
        'countNewMessages': ++count,
      });
    });
  }

  makeCountNewMessagesZero(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .update({
      'countNewMessages': 0,
    });
  }

  updateStatusInFireStore(String myId, String statusText) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({'userStatusText': statusText});
  }

  updateUserNameInFireStore(String myId, String newName) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({'userName': newName});
  }

  updateOnlineStatusInFireStore(String thisUserId, bool onlineStatus) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(thisUserId)
        .update({
      'isOnline': onlineStatus,
    });
  }

  updateLastSeenInFirestore(String thisUserId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(thisUserId)
        .update({
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

  updateUserNameInAllChatRooms(String myId, String newName) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('users', arrayContains: myId)
        .snapshots()
        .forEach((element) {
      element.docs.forEach((element) {
        //update
        FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(element.id)
            .update({
          'usersName': {
            myId: newName,
          },
        });
      });
    });
  }
}
