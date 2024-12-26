import 'package:flutter/material.dart';

Widget cardWidget({
  required String title,
  required Color color,
  required Color titleColor,
  required VoidCallback onPressed,
  required VoidCallback onDoubleTap,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click, // Change mouse cursor to pointer
    child: GestureDetector(
      onTap: onPressed,
      onDoubleTap: onDoubleTap,
      child: Card(
        color: color,
        elevation: 8, // Add elevation to create the 3D effect
        shadowColor: Colors.grey.withOpacity(0.5), // Shadow color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onPressed,
          onDoubleTap: onDoubleTap,
          highlightColor: Colors.grey.withOpacity(0.3), // Highlight color
          splashColor: Colors.grey.withOpacity(0.1), // Splash color
          borderRadius: BorderRadius.circular(12), // Same border radius as card
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: titleColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
