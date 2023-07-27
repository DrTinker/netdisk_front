import 'dart:ui';

import 'package:flutter/material.dart';

class MyPathClipper extends CustomClipper<Path> {
  static const double hollowRatio = 1 / 4;
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * hollowRatio,
        height: size.height * hollowRatio));
    path.addOval(Offset.zero & size);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}