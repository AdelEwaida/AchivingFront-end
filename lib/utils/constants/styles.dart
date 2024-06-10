import 'dart:ui';

import 'package:flutter/material.dart';

ButtonStyle customButtonStyle(Size size, double fontSize, Color color) {
  return ElevatedButton.styleFrom(
      backgroundColor: color,
      fixedSize: size,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.normal),
      alignment: Alignment.center);
}
