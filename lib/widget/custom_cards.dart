import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCards extends StatefulWidget {
  // double width;
  double height;
  Widget? content;
  CustomCards({
    super.key,
    // required this.width,
    required this.height,
    this.content,
  });

  @override
  State<CustomCards> createState() => _CustomCardsState();
}

class _CustomCardsState extends State<CustomCards> {
  double spreadRadius = 1;
  double blurRadius = 10;
  @override
  Widget build(BuildContext context) {
    // double width = widget.width;
    double height = widget.height;

    Widget content = widget.content ??
        const Center(
          child: const Text("NO DATA"),
        );

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          spreadRadius = 6;
        });
      },
      onExit: (event) {
        setState(() {
          spreadRadius = 1;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              spreadRadius: spreadRadius,
              offset: const Offset(0, 8),
              blurRadius: blurRadius,
              color: Colors.grey.withOpacity(0.3),
            )
          ],
        ),
        width: 100,
        height: height,
        child: content,
      ),
    );
  }
}
