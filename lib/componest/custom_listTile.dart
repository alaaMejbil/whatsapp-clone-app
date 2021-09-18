// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {Key? key,
      required this.leadingIcon,
      required this.title,
      @required this.onTap,
      required this.iconColor})
      : super(key: key);

  final IconData leadingIcon;
  final String title;
  final Color iconColor;
  // ignore: prefer_typing_uninitialized_variables
  final onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    height: 30.0,
                    width: 30.0,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      leadingIcon,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// Container(
// child: Icon(
// this.leadingIcon,
// color: this.iconColor,
// size: 40.0,
// ),
// ),
