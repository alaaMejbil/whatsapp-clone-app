// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notifiaction_app/componest/chatRoom_listTile_inAllmember.dart';
import 'package:notifiaction_app/services/auth.dart';
import 'package:notifiaction_app/services/shared_method.dart';

import '../constans.dart';
import '../main.dart';

class AllMembersScreen extends StatefulWidget {
  const AllMembersScreen({Key? key}) : super(key: key);

  @override
  _AllMembersScreenState createState() => _AllMembersScreenState();
}

class _AllMembersScreenState extends State<AllMembersScreen> {
  AllMembersScreenState() {
    //Register a closure to be called when the object changes.
    _searchTextField.addListener(() {
      if (_searchTextField.text.isEmpty) {
        //Notify the framework that the internal state of this object has changed.
        setState(() {
          _isTextFieldEmpty = true;
          _query = "";
        });
      } else {
        setState(() {
          _isTextFieldEmpty = false;
          _query = _searchTextField.text;
        });
      }
    });
  }

  String? myId;
  String? myUserName;
  String? myImageUrl;

  int usersNumbers = 0;

  final TextEditingController _searchTextField = TextEditingController();
  bool _isSearching = false;
  bool _isTextFieldEmpty = true;
  String _query = "";

  List<DocumentSnapshot> current_users = [];
  late List<Widget> _filterList;

  Future getMyInfoFromShared() async {
    myId = (await SharedMethod().getUserId())!;
    myUserName = (await SharedMethod().getUserName())!;
    // myImageUrl = (await SharedMethod().getUserProfileUrl())!;
    setState(() {});

    print('my userName from shared is $myUserName');
    //get my myUserName From FireStore
    if (myUserName == "") {
      print('get my myUserName From FireStore');
      var snapshot =
          await FirebaseFirestore.instance.collection('users').doc(myId).get();
      setState(() {
        myUserName = snapshot.data()!['userName'];
      });
      await SharedMethod().saveUserStatus(myUserName!);
      print('my userName from FireStore is $myUserName');
    }
  }

  getNumberUsersInDB() async {
    print('getNumberUsersInDB is run ');
    print('myId is $myId');
    await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isNotEqualTo: myId)
        .get()
        .then((value) {
      setState(() {
        usersNumbers = value.docs.length;
      });
    });
  }

  @override
  void initState() {
    () async {
      await getMyInfoFromShared();
      await getNumberUsersInDB();
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: getAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'My Friends',
                style: kTittleTextStyle,
              ),
            ),
            const Divider(
              color: primary,
              height: 5,
            ),
            //_firstSearch ? _createListView() : _performSearch(),

            _isTextFieldEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('userId', isNotEqualTo: myId)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data!.docs;
                      current_users = users;
                      List<Widget> usersList = [];
                      for (var user in users) {
                        usersList.add(UserListTile(
                          myId: myId, // passed it to make chatroomID
                          myUserName: myUserName,
                          contactId: user['userId'],
                          contactName: user['userName'],
                          contactStatus: user['userStatusText'],
                          contactImageUrl: user['userImageUrl'],
                          isOnline: user['isOnline'],
                        ));
                      }
                      return Expanded(
                          child: ListView(
                        children: usersList,
                      ));
                    },
                  )
                : _performSearch(),
          ],
        ),
      ),
    );
  }

  //Create a ListView widget

  Widget _buildSearchField() {
    return TextField(
      controller: _searchTextField,
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

  Widget _performSearch() {
    _filterList = [];
    for (int i = 0; i < current_users.length; i++) {
      var item = current_users[i];
      if (item['userName'].toLowerCase().contains(_query.toLowerCase())) {
        _filterList.add(UserListTile(
          myId: myId, // passed it to make chatroomID
          myUserName: myUserName,
          contactId: item['userId'],
          contactName: item['userName'],
          contactStatus: item['userStatusText'],
          contactImageUrl: item['userImageUrl'],
          isOnline: item['isOnline'],
        ));
      }
    }
    setState(() {});
    return _filterList.isEmpty
        ? const NoSrearchedResults()
        : Expanded(
            child: ListView(
            children: _filterList,
          ));
  }

  AppBar getAppBar(BuildContext ctx) {
    return AppBar(
      backgroundColor: bgColor,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primary, size: 25.0),
          onPressed: () {
            Navigator.pop(context);
          }),
      title: _isSearching
          ? _buildSearchField()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Contact',
                  style: kLabetTextStyle.copyWith(
                      fontSize: 21, letterSpacing: 0.6),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (usersNumbers > 0)
                  Text(
                    '$usersNumbers contacts',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 16,
                    ),
                  ),
              ],
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
              if (_searchTextField == null || _searchTextField.text.isEmpty) {
                setState(() {
                  _isSearching = false;
                });
                return;
              }
              // if textField not empty
              setState(() {
                _searchTextField.clear();
                //updateSearchQuery("");
              });
            },
          ),
      ],
    );
  }
}

class NoSrearchedResults extends StatelessWidget {
  const NoSrearchedResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_sharp,
            color: primary,
            size: 50,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'No results',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            'Try a new search',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

PopupMenuButton<dynamic> _buildChatPopupMenuButton() {
  return PopupMenuButton(
    color: Colors.blue.withOpacity(0.4),
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
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              const SizedBox(
                width: 15,
              ),
              const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          value: 'logout',
        ),
      ];
    },
    onSelected: (val) {
      if (val == 'logout') {
        AuthMethode().signOut();
      }
    },
  );
}
