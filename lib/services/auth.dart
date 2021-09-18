import 'package:notifiaction_app/componest/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:notifiaction_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

class AuthMethode {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getCurrentUsre() async {
    return await _auth.currentUser;
  }

  signIn(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ChatScreen(
                      contactImageUrl: '',
                      contactId: '',
                      contactUserName: '',
                      chatRoomId: '',
                      myId: '',
                    )));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'an Error Acourd !';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  signUp(
      {required String email,
      required String password,
      required String username,
      required BuildContext context}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // add user information to Firestore
      dynamic userInfoMap = {
        'email': email,
        'password': password,
        'userName': username,
      };
      await DatabaseMethods()
          .addUserInfoToDB(userCredential.user!.uid, userInfoMap);

      if (userCredential != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ChatScreen(
                      contactId: '',
                      myId: '',
                      contactImageUrl: '',
                      chatRoomId: '',
                      contactUserName: '',
                    )));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'an Error Acourd !';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _auth.signOut();
  }
}
