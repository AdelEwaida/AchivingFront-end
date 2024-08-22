import 'dart:ui';

import 'package:archiving_flutter_project/utils/constants/colors.dart';
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

ButtonStyle customButtonStyle1(Size size, double fontSize, Color color) {
  return ElevatedButton.styleFrom(
      backgroundColor: color,
      fixedSize: size,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      ),
      alignment: Alignment.center);
}

Widget blueButton1({
  width,
  onPressed,
  height,
  textColor,
  fontSize,
  fontWeight,
  Icon? icon, // New parameter for the icon
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Make it circular
        // side: BorderSide(
        //   color: primary,
        //   width: 1.0,
        // ),
      ),
      padding: EdgeInsets.all(0),
      minimumSize: Size(width ?? 50.0, height ?? 50.0),
      // Remove the primary color from styleFrom since it's set in the gradient
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 65, 114, 193), primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          // Container(
          //   alignment: Alignment.center,
          //   padding: const EdgeInsets.all(10),
          //   // child: Text(
          //   //   "" ?? text.toString(),
          //   //   style: TextStyle(
          //   //     color: textColor ?? whiteColor,
          //   //     fontSize: fontSize ?? 13,
          //   //     fontWeight: fontWeight ?? FontWeight.bold,
          //   //   ),
          //   // ),
          // ),
        ],
      ),
    ),
  );
}
