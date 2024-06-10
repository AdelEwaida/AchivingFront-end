import 'package:flutter/material.dart';

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0.0, 0.0); // Move to top-left corner
    path.quadraticBezierTo(0, size.height * 0.4, size.width * 0.3,
        size.height); // Create a concave curve
    path.lineTo(size.width, size.height); // Line to bottom-right corner
    path.lineTo(size.width, 0.0); // Line to top-right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
