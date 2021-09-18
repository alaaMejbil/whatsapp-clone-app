import 'package:notifiaction_app/componest/auth_form.dart';
import 'package:notifiaction_app/constans.dart';
import 'package:notifiaction_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.6),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(20),
          width: double.infinity,
          //height: size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AuthForm(),
        ),
      ),
    );
  }
}
