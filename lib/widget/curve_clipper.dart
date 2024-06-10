import 'package:flutter/material.dart';

class CircularOneSideClipper extends CustomClipper<Path> {
  final double curveWidth;

  CircularOneSideClipper(this.curveWidth);

  @override
  Path getClip(Size size) {
    final path = Path();
    final adjustedWidth = size.height * curveWidth;

    path.moveTo(adjustedWidth, 0);
    path.arcToPoint(
      Offset(0, size.height / 2),
      radius: Radius.circular(adjustedWidth),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(adjustedWidth, size.height),
      radius: Radius.circular(adjustedWidth),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
