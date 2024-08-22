import 'package:flutter/material.dart';

import '../../utils/func/responsive.dart';

class CardContent extends StatefulWidget {
  final String title;
  final String value;
  final String? dates;
  // final Color color;
  final IconData icon;
  const CardContent({
    super.key,
    required this.title,
    required this.value,
    this.dates,
    // required this.color,
    required this.icon,
  });

  @override
  State<CardContent> createState() => _CardContentState();
}

class _CardContentState extends State<CardContent> {
  double radius = 5;
  @override
  Widget build(BuildContext context) {
    String title = widget.title;
    String value = widget.value;
    IconData icon = widget.icon;
    String dates = widget.dates ?? "";

    bool isMobile = Responsive.isMobile(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (dates.isNotEmpty)
                      Text(
                        dates,
                        style: const TextStyle(fontSize: 10),
                      ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (dates.isNotEmpty)
                      Text(
                        dates,
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      fontSize: isMobile ? 12 : 25,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  icon,
                  size: isMobile ? 20 : 50,
                ),
              ],
            ),
          ),
        ),
        // Container(
        //   height: 15,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.only(
        //         bottomLeft: Radius.circular(radius),
        //         bottomRight: Radius.circular(radius)),
        //     color: color,
        //   ),
        // ),
      ],
    );
  }
}
