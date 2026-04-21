import 'package:flutter/material.dart';

class ChartCards extends StatefulWidget {
  final double height;
  final Widget? content;
  final Color accentColor;

  const ChartCards({
    super.key,
    required this.height,
    this.content,
    this.accentColor = Colors.red,
  });

  @override
  State<ChartCards> createState() => _ChartCardsState();
}

class _ChartCardsState extends State<ChartCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = widget.content ??
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 32, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(
                "No data available",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor
                        .withOpacity(0.08 + 0.1 * _elevationAnim.value),
                    blurRadius: 16 + 8 * _elevationAnim.value,
                    spreadRadius: _elevationAnim.value * 2,
                    offset: Offset(0, 4 + 2 * _elevationAnim.value),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: child!,
              ),
            ),
          );
        },
        child: content,
      ),
    );
  }
}
