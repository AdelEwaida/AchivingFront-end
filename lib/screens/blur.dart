import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredBackground extends StatelessWidget {
  final String imagePath;
  final double blurSigmaX;
  final double blurSigmaY;

  const BlurredBackground({
    Key? key,
    required this.imagePath,
    this.blurSigmaX = 10.0,
    this.blurSigmaY = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
            child: Container(
              color: Colors
                  .transparent, // Transparent to make the blur effect visible
            ),
          ),
        ),
      ],
    );
  }
}
