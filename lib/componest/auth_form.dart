import 'package:notifiaction_app/constans.dart';
import 'package:notifiaction_app/screens/tabs_screen.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:notifiaction_app/services/shared_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../userProvider.dart';

enum AuthMode { SignUp, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final Key _k1 = GlobalKey();
  final Key _k2 = GlobalKey();
  final Key _k3 = GlobalKey();
  final Key _k4 = GlobalKey();

  String _email = "";
  String _username = "";
  String _password = "";
  String statusText = "";

  AuthMode _authMode = AuthMode.Login;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Icon(
                  Icons.add_comment_rounded,
                  size: 40,
                  color: primary,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text(
                      'WhatsApp Clone',
                      style: TextStyle(
                        color: primary,
                        fontSize: 45,
                        fontFamily: 'Signatra',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _textFormFieldEmail(),
            _buildSizedBox(),
            if (_authMode == AuthMode.SignUp) _textFieldUserName(),
            if (_authMode == AuthMode.SignUp) _buildSizedBox(),
            _textFieldPassword(),
            _buildSizedBox(),
            if (_authMode == AuthMode.SignUp) _textFieldConfirmPassword(),
            if (_authMode == AuthMode.SignUp) _buildSizedBox(),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              RaisedButton(
                  color: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _authMode == AuthMode.Login ? 'Login' : 'Sign UP',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final isValid = _formKey.currentState!.validate();
                    FocusScope.of(context).unfocus();

                    if (isValid) {
                      _formKey.currentState!.save();
                      await _submitAuthForm();
                    }
                  }),
            if (!_isLoading)
              FlatButton(
                onPressed: () {
                  setState(() {
                    _authMode == AuthMode.Login
                        ? _authMode = AuthMode.SignUp
                        : _authMode = AuthMode.Login;
                  });
                },
                child: Text(
                  _authMode == AuthMode.Login
                      ? 'Creat New Account '
                      : 'I already have account',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _flatButtonFunction() {
    setState(() {
      _authMode == AuthMode.Login
          ? _authMode = AuthMode.SignUp
          : _authMode = AuthMode.Login;
    });
  }

  void startLoading(bool isloading) {
    setState(() {
      _isLoading = isloading;
    });
  }

  Future<void> _submitAuthForm() async {
    startLoading(true);
    try {
      final _auth = FirebaseAuth.instance;
      UserCredential userCredential;
      //            //
      // Login Mode //
      //            //
      if (_authMode == AuthMode.Login) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // ignore: unnecessary_null_comparison
        if (userCredential != null) {
          // save user data in shared prefernces
          print('my Id from Login is : ${userCredential.user!.uid}');
          await saveUserInfoInShared(userCredential);

          ///get my status From FireStore
          print('get my status From FireStore');
          var snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
          statusText = snapshot.data()!["userStatusText"];
          print('get my status now is :$statusText');

          /// await SharedMethod().saveUserStatus(statusText);

          /// make isOnline True
          print('make isOnline True !!!!!!!!!!!!!!!!!');
          await DatabaseMethods()
              .updateOnlineStatusInFireStore(userCredential.user!.uid, true);
          //
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => MyApp()));

        } else {
          print('userCredential is Null !!!!!!!!!!!!!!!!!');
        } //
        // SignUp
        //
      } else if (_authMode == AuthMode.SignUp) {
        print('Start SignUp ..............');
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // ignore: unnecessary_null_comparison
        if (userCredential != null) {
          /// save user data in shared prefernces
          print('1 - save user data in shared prefernces');
          await saveUserInfoInShared2(userCredential);
          print('1.2 - Finish save user data in shared prefernces');

          print('2 - add user information to Firestore');

          /// add user information to Firestore
          dynamic userInfoMap = {
            'email': _email,
            'password': _password,
            'userName': _username,
            'userId': userCredential.user!.uid,
            'userStatusText': 'Hey there ! I am using Clone WhatsApp',
            'userImageUrl': "",
            'isOnline': true,
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          };

          await DatabaseMethods()
              .addUserInfoToDB(userCredential.user!.uid, userInfoMap);
          // print('3 - go to MyApp() ');
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => TabsScreen(
          //       myId: userCredential.user!.uid,
          //       myName: _username,
          //       tabSelected: 0,
          //     ),
          //   ),
          // );
        }
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
      setState(() => _isLoading = false);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      setState(() => _isLoading = false);
      print(e);
    }
  }

  Future<void> saveUserInfoInShared2(UserCredential userCredential) async {
    await SharedMethod().saveUserId(userCredential.user!.uid);
    //await SharedMethod().saveUserEmail(userCredential.user.email);
    await SharedMethod().saveUserName(_username);
    await SharedMethod()
        .saveUserStatus('Hey there ! I am using whatsapp clone.');
  }

  Future saveUserInfoInShared(UserCredential userCredential) async {
    await SharedMethod().saveUserId(userCredential.user!.uid);
    //await SharedMethod().saveUserEmail(userCredential.user!.email);
    await SharedMethod().saveUserName(_username);
    print('saved userName in shared done !!!!!!');
    await SharedMethod().saveUserStatus(statusText);
  }

  SizedBox _buildSizedBox() {
    return const SizedBox(
      height: 20,
    );
  }

  TextFormField _textFormFieldEmail() {
    return TextFormField(
      key: _k1,
      keyboardType: TextInputType.emailAddress,
      onSaved: (val) => _email = val!,
      validator: (val) {
        if (val!.isEmpty || !(val.contains('@'))) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'Email Address',
        prefixIcon: Icon(Icons.email_sharp),
      ),
    );
  }

  TextFormField _textFieldUserName() {
    return TextFormField(
      key: _k2,
      keyboardType: TextInputType.name,
      onSaved: (val) {
        setState(() {
          _username = val!;
        });
      },
      validator: (val) {
        if (val!.isEmpty) {
          return 'Please enter username';
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'User Name',
        prefixIcon: Icon(Icons.account_circle_rounded),
      ),
    );
  }

  TextFormField _textFieldPassword() {
    return TextFormField(
      obscureText: true,
      key: _k3,
      onChanged: (val) {
        setState(() {
          _password = val;
        });
      },
      validator: (val) {
        if (val!.isEmpty) {
          return 'Please enter a Password';
        } else if (val.length < 6) {
          return 'you must enter password great than 6';
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'Password',
        prefixIcon: Icon(Icons.vpn_key_sharp),
      ),
    );
  }

  TextFormField _textFieldConfirmPassword() {
    return TextFormField(
      key: _k4,
      obscureText: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'Please enter a Password';
        } else if (val != _password) {
          return 'Password not Match !';
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'Confirm Password',
        prefixIcon: Icon(Icons.vpn_key_sharp),
      ),
    );
  }
}
