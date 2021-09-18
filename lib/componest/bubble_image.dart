import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:notifiaction_app/constans.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:toast/toast.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BubbleImage extends StatefulWidget {
  final String imgUrl;
  final String userName;
  final int msgTime;
  final bool isMe;
  final bool isMsgRead;

  const BubbleImage(
      {Key? key,
      required this.imgUrl,
      required this.userName,
      required this.msgTime,
      required this.isMe,
      required this.isMsgRead})
      : super(key: key);

  @override
  _BubbleImageState createState() => _BubbleImageState();
}

class _BubbleImageState extends State<BubbleImage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      //height: 180,
      margin: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: widget.isMe ? 10 : size.width * 0.4,
        right: widget.isMe ? size.width * 0.4 : 10,
      ),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.lightGreen[200] : Colors.blueGrey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(children: [
        Container(
          //width: 500,
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: widget.imgUrl,
              placeholder: (context, url) => Container(
                transform: Matrix4.translationValues(0, 0, 0),
                child: Container(
                    height: 160,
                    child: Center(child: new CircularProgressIndicator())),
              ),
              errorWidget: (context, url, error) => new Icon(Icons.error),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 2,
          child: IconButton(
            icon: const Icon(
              Icons.save_alt_sharp,
              size: 30,
              color: Colors.green,
            ),
            onPressed: downloadFile,
          ),
        ),
        Positioned(
          bottom: 3,
          right: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('kk:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(this.widget.msgTime)),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                //if (isMe)
                const SizedBox(
                  width: 1,
                ),
                //if (isMe)
                Icon(
                  Icons.check,
                  size: 22,
                  color: this.widget.isMsgRead ? Colors.blue : Colors.grey,
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }

  final Dio dio = Dio();

  bool loading = false;

  double progress = 0;

  Future<bool> saveFile(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/WhatsappClone";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        // if (Platform.isIOS) {
        //   await ImageGallerySaver.saveFile(saveFile.path,
        //       isReturnPathOfIOS: true);
        // }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });

    String imageName = "image_${DateTime.now()}.jpg";
    bool downloaded = await saveFile(widget.imgUrl, imageName);
    if (downloaded) {
      print("File Downloaded");
      //Toast.show("File Downloaded", context, duration: Toast.LENGTH_SHORT);
    } else {
      print("Problem Downloading File");
      // Toast.show("Problem Downloading File", context,
      //     duration: Toast.LENGTH_SHORT);
    }
    setState(() {
      loading = false;
    });
  }
}
