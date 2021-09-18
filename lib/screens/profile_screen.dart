import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:notifiaction_app/screens/tabs_screen.dart';
import 'package:notifiaction_app/services/database.dart';
import 'package:notifiaction_app/services/shared_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

//import 'package:random_string/random_string.dart';

import '../constans.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String? imageUrl;
  final String? statusText;
  final String? userName;

  // ignore: use_key_in_widget_constructors
  const ProfileScreen(
      {required this.imageUrl,
      required this.statusText,
      required this.userName,
      required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String myId = "";
  String myUserName = "";
  late String myImageUrl;
  String newStatusText = "";

  bool isLoading = false;

  void getMyInfoFromSharedAndFS() async {
    // myId = await SharedMethod().getUserId();
    // myUserName = await SharedMethod().getUserName();
    // setState(() {});
    // print('My ID is : $myId');
    //print('My status is : $statusText');

    // //get my status From FireStore
    // if (statusText == "") {
    //   print('get my status From FireStore');
    //   var snapshot =
    //       await FirebaseFirestore.instance.collection('users').doc(myId).get();
    //   setState(() {
    //     statusText = snapshot.data()['userStatusText'];
    //   });
    // }
    //get my imag url from FS
    // if (myImageUrl == "") {
    //   print('get my imag url from FS');
    //   var snapshot =
    //       await FirebaseFirestore.instance.collection('users').doc(myId).get();
    //   setState(() {
    //     myImageUrl = snapshot.data()['userImageUrl'];
    //   });
    // }
  }

  final TextEditingController _newUserName = TextEditingController()..text = "";
  final TextEditingController _newStatus = TextEditingController()..text = "";

  // uploadImage() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   // String randomImageName = "${randomAlphaNumeric(12)}.jpg";
  //   String randomImageName = "${DateTime.now()}.jpg";
  //   try {
  //     final ref = FirebaseStorage.instance
  //         .ref()
  //         .child('user_images')
  //         .child(randomImageName);
  //
  //     await ref.putFile(_image);
  //
  //     myImageUrl = await ref.getDownloadURL();
  //     setState(() {});
  //     // update image url in FireStore
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(myId)
  //         .update({'userImageUrl': myImageUrl});
  //
  //     //save image profile url in shared
  //     SharedMethod().saveUserProfileUrl(myImageUrl);
  //     // _image = null;
  //
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('ERROR : $e');
  //   }
  // }

// late File _image;
  // final picker = ImagePicker();
  //
  // Future getImage(ImageSource src) async {
  //   final pikedFile = await picker.getImage(
  //     source: src,
  //     imageQuality: 20,
  //   );
  //   setState(() {
  //     if (pikedFile != null) {
  //       setState(() {
  //         _image = File(pikedFile.path);
  //
  //         if (_image != null) {
  //           uploadImage();
  //         }
  //       });
  //     } else {
  //       print('No image selected');
  //     }
  //   });
  // }

  @override
  void initState() {
    //getMyInfoFromSharedAndFS();
    setState(() {
      myId = widget.userId;
      myUserName = widget.userName!;
      newStatusText = widget.statusText!;
      myImageUrl = widget.imageUrl!;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: getAppBar(),
      body: SingleChildScrollView(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                isLoading
                    ? Material(
                        borderRadius: BorderRadius.circular(150),
                        clipBehavior: Clip.hardEdge,
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          width: 180,
                          height: 180,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ))
                    : (myImageUrl != "")
                        ? Hero(
                            tag: 'imageHero',
                            child: Material(
                              borderRadius: BorderRadius.circular(150),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  width: 180,
                                  height: 180,
                                  padding: const EdgeInsets.all(20),
                                ),
                                fadeInDuration: const Duration(milliseconds: 0),
                                fadeOutDuration:
                                    const Duration(milliseconds: 0),
                                imageUrl: myImageUrl,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Material(
                            borderRadius: BorderRadius.circular(100),
                            clipBehavior: Clip.hardEdge,
                            child: const Icon(
                              Icons.account_circle,
                              color: Colors.grey,
                              size: 150,
                            ),
                          ),
                Positioned(
                  bottom: 8,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      buildShowModalBottomSheetForImage(context);
                    },
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: primary,
                      child: Icon(
                        Icons.camera_alt,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              color: Colors.white.withOpacity(0.4),
            ),
            ListTile(
              onTap: () {
                buildShowModalBottomSheetUserName(context);
              },
              leading: const Icon(
                Icons.account_circle_rounded,
                color: primary,
              ),
              title: const Text(
                'User Name',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              subtitle: Text(
                myUserName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(
                Icons.edit,
                color: primary,
              ),
            ),
            Divider(
              color: Colors.white.withOpacity(0.4),
            ),
            ListTile(
              onTap: () => buildShowModalBottomSheetForStatus(context),
              leading: const Icon(
                Icons.add_circle_outlined,
                color: primary,
              ),
              title: const Text(
                'Status',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              subtitle: Text(
                newStatusText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(
                Icons.edit,
                color: primary,
              ),
            ),
            Divider(
              color: Colors.white.withOpacity(0.4),
            ),
            ListTile(
              leading: const Icon(
                Icons.phone,
                color: primary,
              ),
              title: const Text(
                'Phone number',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              subtitle: Text(
                '+963 959 886 594',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(
                Icons.edit,
                color: primary,
              ),
            ),
            Divider(
              color: Colors.white.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      backgroundColor: bgColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: primary,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TabsScreen(myId: myId, myName: myUserName, tabSelected: 3),
            ),
          );
        },
      ),
      title: const Text(
        'Profile',
        style: kTittleTextStyle,
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheetForImage(BuildContext ctx) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        context: ctx,
        builder: (ctx) {
          return Wrap(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Profile photo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            ////////////// await getImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 25,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const Text('Camera'),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            ////////////await getImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 25,
                                    child: Icon(
                                      Icons.panorama_sharp,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const Text('Gallery'),
                              ],
                            ),
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

  Future<dynamic> buildShowModalBottomSheetUserName(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 20,
                    right: 20,
                    left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your name',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newUserName,
                            autofocus: true,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: primary, fontSize: 18),
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            //1- refresh in UI
                            myUserName = _newUserName.text;
                            //2 - update userName in Firestore
                            await DatabaseMethods()
                                .updateUserNameInFireStore(myId, myUserName);

                            //3 - Save new UserName in Shared
                            await SharedMethod().saveUserName(myUserName);
                            setState(() {});

                            Navigator.pop(context);
                            _newUserName.clear();
                          },
                          child: const Text(
                            'SAVE',
                            style: TextStyle(color: primary, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future<dynamic> buildShowModalBottomSheetForStatus(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 20,
                    right: 20,
                    left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your Status',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newStatus,
                            autofocus: true,
                            decoration: const InputDecoration(),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: primary, fontSize: 18),
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            newStatusText = _newStatus.text;
                            await DatabaseMethods()
                                .updateStatusInFireStore(myId, newStatusText);
                            await SharedMethod().saveUserStatus(newStatusText);
                            setState(() {});

                            Navigator.pop(context);
                            _newStatus.clear();
                          },
                          child: const Text(
                            'SAVE',
                            style: TextStyle(color: primary, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
