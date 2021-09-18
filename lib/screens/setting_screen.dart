import 'package:cached_network_image/cached_network_image.dart';
import 'package:notifiaction_app/componest/custom_listTile.dart';
import 'package:notifiaction_app/screens/profile_screen.dart';
import 'package:notifiaction_app/services/shared_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constans.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String myId = "";
  String? myStatusText;
  String? myImageUrl = "";
  String? myName;

  Future getMyDataFromShared() async {
    //try get my Data From Shared
    // ignore: avoid_print
    print('try get my Data From Shared');
    myId = (await SharedMethod().getUserId())!;
    myName = await SharedMethod().getUserName();
    myStatusText = await SharedMethod().getUserStatus();
    myImageUrl = await SharedMethod().getUserProfileUrl() ?? "";

    if (myImageUrl == "") {
      //get my Image Url From FS
      print('get my Image Url From FS');
      var snapshot =
          await FirebaseFirestore.instance.collection('users').doc(myId).get();
      myImageUrl = snapshot.data()!["userImageUrl"];
      if (myImageUrl != "") {
        await SharedMethod().saveUserProfileUrl(myImageUrl!);
      }
      setState(() {});
    }

    //get my status From FireStore
    if (myStatusText == "") {
      print('get my status From FireStore');
      var snapshot =
          await FirebaseFirestore.instance.collection('users').doc(myId).get();
      setState(() {
        myStatusText = snapshot.data()!['userStatusText'];
      });
      await SharedMethod().saveUserStatus(myStatusText!);
    }

    //get my username From FireStore
    if (myName == "") {
      print('get my Name From FireStore');
      var snapshot =
          await FirebaseFirestore.instance.collection('users').doc(myId).get();
      setState(() {
        myName = snapshot.data()!['userName'];
      });
      await SharedMethod().saveUserName(myName!);
    }

    setState(() {});
    print('my ID is : $myId');
    print('my UserName is : $myName');
    print('my Status is : $myStatusText');
    print('my URL is : $myImageUrl');
  }

  @override
  void initState() {
    print(
        'init() here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1');
    () async {
      await getMyDataFromShared();
    }();

    super.initState();
  }

  //String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        title: const Text(
          'Settings',
          style: kTittleTextStyle,
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    // ignore: avoid_unnecessary_containers
                    child: Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userId: myId,
                                userName: myName,
                                imageUrl: myImageUrl,
                                statusText: myStatusText,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            (myImageUrl != "")
                                ? Hero(
                                    tag: 'imageHero',
                                    child: Material(
                                      borderRadius: BorderRadius.circular(150),
                                      clipBehavior: Clip.hardEdge,
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                          width: 70,
                                          height: 70,
                                          padding: const EdgeInsets.all(20),
                                        ),
                                        fadeInDuration:
                                            const Duration(milliseconds: 0),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 0),
                                        imageUrl: myImageUrl!,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    child: Icon(
                                      Icons.account_circle,
                                      color: Colors.grey.shade600,
                                      size: 60,
                                    ),
                                    radius: 30,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.7),
                                  ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    myName ?? "",
                                    style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  // ignore: sized_box_for_whitespace
                                  Container(
                                    width: 220.0,
                                    child: Text(
                                      myStatusText ?? "",
                                      style: TextStyle(
                                        fontSize: 15.0,
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
                    ),
                  ),
                  Container(
                    height: 38.0,
                    width: 38.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.border_all,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
          CustomListTile(
            title: 'Starred Messagse',
            leadingIcon: Icons.star,
            iconColor: Colors.yellow.shade800,
            onTap: () {
              print('pressed!');
            },
          ),
          CustomListTile(
            title: 'WhatsApp Web',
            leadingIcon: Icons.computer,
            iconColor: Colors.green,
            onTap: () {},
          ),
          const SizedBox(
            height: 50.0,
          ),
          CustomListTile(
            title: 'Account',
            leadingIcon: Icons.supervisor_account,
            iconColor: Colors.blue,
            onTap: () {},
          ),
          CustomListTile(
            title: 'Chats',
            leadingIcon: Icons.chat_bubble,
            iconColor: Colors.greenAccent,
            onTap: () {},
          ),
          CustomListTile(
            title: 'Notifications',
            leadingIcon: Icons.notifications,
            iconColor: Colors.red,
            onTap: () {},
          ),
          CustomListTile(
            title: 'Storage and Data',
            leadingIcon: Icons.storage,
            iconColor: Colors.green,
            onTap: () {},
          ),
          const SizedBox(
            height: 50.0,
          ),
          CustomListTile(
            title: 'Help',
            leadingIcon: Icons.live_help,
            iconColor: Colors.blue,
            onTap: () {},
          ),
          CustomListTile(
            title: 'Tell a Friend',
            leadingIcon: Icons.favorite,
            iconColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
