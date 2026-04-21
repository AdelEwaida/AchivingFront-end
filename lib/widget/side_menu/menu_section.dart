import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  final double width;
  final List<dynamic> menuList;
  final Widget Function(dynamic menu, int index) itemBuilder;
  final ScrollController scrollController;
  final String logoPath;
  final double logoWidthFactor;

  const MenuSection({
    super.key,
    required this.width,
    required this.menuList,
    required this.itemBuilder,
    required this.scrollController,
    required this.logoPath,
    this.logoWidthFactor = 0.075,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              logoPath,
              width: width * logoWidthFactor,
              fit: BoxFit.contain,
            ),
           
          ],
        ),
        const SizedBox(width: 10),
        Container(
          height: 42,
          width: 1,
          color: Colors.white.withOpacity(0.35),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent &&
                  scrollController.hasClients) {
                final current = scrollController.offset;
                final max = scrollController.position.maxScrollExtent;
                final next = (current + pointerSignal.scrollDelta.dy)
                    .clamp(0.0, max)
                    .toDouble();
                scrollController.jumpTo(next);
              }
            },
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < menuList.length; i++) ...[
                    itemBuilder(menuList[i], i),
                    if (i != menuList.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
