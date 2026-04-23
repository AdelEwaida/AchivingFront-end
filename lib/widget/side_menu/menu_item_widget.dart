import 'package:flutter/material.dart';
import '../../models/dto/side_menu/menu_model.dart';

class MenuItemWidget extends StatelessWidget {
  final MenuModel menu;
  final GlobalKey? itemKey;
  final GlobalKey? arrowKey;
  final bool isSelected;
  final bool isOpened;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback? onArrowTap;
  final VoidCallback onHover;
  final VoidCallback onExit;

  const MenuItemWidget({
    super.key,
    required this.menu,
    this.itemKey,
    this.arrowKey,
    required this.isSelected,
    required this.isOpened,
    required this.isHovered,
    required this.onTap,
    this.onArrowTap,
    required this.onHover,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isParent = menu.isParent;

    return MouseRegion(
      onEnter: (_) => onHover(),
      onExit: (_) => onExit(),
      child: AnimatedContainer(
        key: itemKey,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        decoration: _buildDecoration(),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 11 : 14,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Icon(
                    menu.icon,
                    size: 18,
                    color: isSelected ? const Color(0xFFFFF8E1) : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    menu.title,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFFFFF8E1) : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (isParent) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      key: arrowKey,
                      behavior: HitTestBehavior.opaque,
                      onTap: onArrowTap,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isOpened
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: isSelected
                              ? const Color(0xFFFFF8E1)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    if (isSelected) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC107).withOpacity(0.34),
            const Color(0xFFFF9800).withOpacity(0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA000).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: isHovered ? Colors.grey.withOpacity(0.3) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    );
  }
}
