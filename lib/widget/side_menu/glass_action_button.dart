import 'package:flutter/material.dart';

class GlassActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  const GlassActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.size = 34,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
