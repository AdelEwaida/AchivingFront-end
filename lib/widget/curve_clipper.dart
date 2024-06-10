import 'package:flutter/material.dart';
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

// class CircularOneSideClipper extends CustomClipper<Path> {
//   final double curveWidth;

//   CircularOneSideClipper(this.curveWidth);

//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     final adjustedWidth = size.height * curveWidth;

//     path.moveTo(adjustedWidth, 0);
//     path.arcToPoint(
//       Offset(0, size.height / 2),
//       radius: Radius.circular(adjustedWidth),
//       clockwise: false,
//     );
//     path.arcToPoint(
//       Offset(adjustedWidth, size.height),
//       radius: Radius.circular(adjustedWidth),
//       clockwise: false,
//     );
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
