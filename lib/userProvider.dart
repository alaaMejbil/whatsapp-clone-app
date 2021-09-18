import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String userEmail = "";

  void set_user(String email) {
    userEmail = email;
    notifyListeners();
  }
}
