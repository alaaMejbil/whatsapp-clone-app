import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifiaction_app/componest/chatRoom_list_tile.dart';
import 'package:notifiaction_app/main.dart';
import 'package:notifiaction_app/screens/all_members.dart';
import 'package:notifiaction_app/screens/chatsroom_screen.dart';
import 'package:notifiaction_app/screens/setting_screen.dart';
import 'package:notifiaction_app/screens/status_screen.dart';
import 'package:notifiaction_app/services/auth.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:notifiaction_app/services/shared_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constans.dart';
import 'call_screen.dart';

class TabsScreen extends StatefulWidget {
  final String myId;
  final int tabSelected;
  final String? myName;

  const TabsScreen(
      {Key? key,
      required this.myId,
      required this.tabSelected,
      required this.myName})
      : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with WidgetsBindingObserver {
  TextEditingController searchTextField = TextEditingController();

  //String myId = "";
  // String myUserName = "";
  // String myImageUrl = "";
  //
  // void getMyInfoFromShared() async {
  //   myId = await SharedMethod().getUserId();
  //   // myUserName = await SharedMethod().getUserName();
  //   // myImageUrl = await SharedMethod().getUserProfileUrl();
  //   setState(() {});
  // }

  bool _isSearching = false;
  String _query = "";
  String id = "";

  @override
  void initState() {
    print('My Id in Tab Screen is ${widget.myId} ');
    print('My Name in Tab Screen is ${widget.myName} ');
    //getMyInfoFromShared();
    WidgetsBinding.instance!.addObserver(this);
    setState(() {
      id = widget.myId;
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('This user Online ${id}');
      await DatabaseMethods().updateOnlineStatusInFireStore(id, true);
    } else {
      print('This user Offline ${id} !!');
      await DatabaseMethods().updateOnlineStatusInFireStore(id, false);
      await DatabaseMethods().updateLastSeenInFirestore(id);
    }
  }

  void showNotification({required String senderName, required String msgText}) {
    // setState(() {
    //   _counter++;
    // });
    print('begain show Notification *******');
    final FlutterLocalNotificationsPlugin _notificationsPlugin =
        FlutterLocalNotificationsPlugin();
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "easyapproach", //id
          "easyapproach channel", //title
          "this is our channel", //description
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
          //largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
        ),
      );

      _notificationsPlugin.show(
        0,
        senderName,
        msgText,
        notificationDetails,
        //payload: message.data['route'],
      );
    } on Exception catch (e) {
      print(e);
    }
    print('*--*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.tabSelected,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: getAppBar(context),
        body: TabBarView(
          children: <Widget>[
            ChatRoomsScreen(
              myId: id,
            ),
            const StatusScreen(),
            const CallsScreen(),
            const SettingPage(),
          ],
        ),
      ),
    );
  }

  AppBar getAppBar(BuildContext ctx) {
    return AppBar(
      backgroundColor: bgColor,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: _isSearching
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: primary, size: 25.0),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                });
              })
          : null,
      title: _isSearching
          ? _buildSearchField()
          : const Text(
              'WhatsApp Clone',
              style: TextStyle(
                color: primary,
                //fontWeight: FontWeight.bold,
                fontSize: 36,
                fontFamily: 'Signatra',
                letterSpacing: 2,
              ),
            ),
      actions: [
        if (!_isSearching)
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
            icon: Icon(Icons.search, color: primary, size: 25),
          ),
        if (!_isSearching) _buildChatPopupMenuButton(),
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.clear, color: primary, size: 25),
            onPressed: () {
              // if textField is empty
              if (searchTextField == null || searchTextField.text.isEmpty) {
                setState(() {
                  _isSearching = false;
                });
                return;
              }
              // if textField not empty
              setState(() {
                searchTextField.clear();
                //updateSearchQuery("");
              });
            },
          ),
      ],
      bottom: TabBar(
        indicatorColor: primary,
        labelColor: primary,
        isScrollable: true,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w500,
        ),
        // ignore: prefer_const_literals_to_create_immutables
        tabs: <Widget>[
          const Tab(text: 'Chats'),
          const Tab(text: ('Status')),
          const Tab(text: ('Calls')),
          const Tab(text: ('Setting')),
        ],
      ),
    );
  }

  PopupMenuButton<dynamic> _buildChatPopupMenuButton() {
    return PopupMenuButton(
      color: Colors.blue.withOpacity(0.6),
      elevation: 5,
      icon: const Icon(
        Icons.menu,
        color: primary,
        size: 25,
      ),
      itemBuilder: (_) {
        return <PopupMenuItem>[
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  'Setting',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            value: 'setting',
          ),
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            value: 'logout',
          ),
        ];
      },
      onSelected: (val) async {
        if (val == 'logout') {
          print('starting logout.......');
          print('my id now is : ${widget.myId}');
          await DatabaseMethods()
              .updateOnlineStatusInFireStore(widget.myId, false);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          await FirebaseAuth.instance.signOut();

          print('End logout.......');
        }
        if (val == 'setting') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SettingPage()));
        }
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchTextField,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Search ...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30, fontSize: 18),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18.0),
      onChanged: (value) {
        setState(() {
          _query = value;
        });
      },
    );
  }
}
