import 'package:flutter/material.dart';

class CircleImage extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final String url_img;

  // ignore: non_constant_identifier_names
  const CircleImage({Key? key, required this.url_img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.0,
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        shape: BoxShape.circle,
        image: DecorationImage(image: AssetImage(url_img), fit: BoxFit.cover),
      ),
    );
  }
}
