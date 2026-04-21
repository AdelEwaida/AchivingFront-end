import 'package:flutter/material.dart';
import '../../utils/func/responsive.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? total;
  final List<Widget> actions;
  final Color accentColor;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.total,
    this.actions = const [],
    this.accentColor = const Color(0xFF0D9B8A),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), 
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isDesktop ? 15 : 17,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (total != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '($total)',
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 12,
                        color: const Color(0xFF8A94A6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Row(
            children: actions
                .map((btn) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: btn,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
