import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  const Indicator(
      {super.key,
      required this.color,
      required this.text,
      required this.isSquare,
      this.size = 16,
      this.textColor,
      this.textSize});
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  final double? textSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
