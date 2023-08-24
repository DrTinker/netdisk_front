import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CardWidget extends StatelessWidget {
  CardWidget({super.key, required this.content, required this.color, this.width, this.height});
  Widget content;
  Color color;
  double? width;
  double? height;
  @override
  Widget build(BuildContext context) {
    final size =MediaQuery.of(context).size;
    return Container(
      width: width ?? size.width,
      height: height,
      //margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Card(
        color: color,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: content,
        ),
      ),
    );
  }
}