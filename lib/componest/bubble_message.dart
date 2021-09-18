import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BubbleMessage extends StatelessWidget {
  const BubbleMessage({
    Key? key,
    required this.userName,
    required this.msgText,
    required this.isMe,
    required this.msgTime,
    required this.isMsgRead,
  }) : super(key: key);

  final String userName;
  final String? msgText;
  final int msgTime;
  final bool isMe;
  final bool isMsgRead;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 3),
            margin: EdgeInsets.only(
              top: 5,
              bottom: 5,
              left: isMe ? 10 : size.width * 0.25,
              right: isMe ? size.width * 0.25 : 10,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.lightGreen[200] : Colors.blueGrey[200],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
                bottomLeft: isMe ? Radius.circular(0) : Radius.circular(12),
                bottomRight: isMe ? Radius.circular(12) : Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(color: Colors.blue),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        msgText!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(this.msgTime)),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (isMe)
                      const SizedBox(
                        width: 1,
                      ),
                    if (isMe)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: this.isMsgRead ? Colors.blue : Colors.grey,
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
