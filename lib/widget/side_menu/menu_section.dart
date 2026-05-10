import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  final double width;
  final List<dynamic> menuList;
  final Widget Function(dynamic menu, int index) itemBuilder;
  final String logoPath;
  final double logoWidthFactor;

  const MenuSection({
    super.key,
    required this.width,
    required this.menuList,
    required this.itemBuilder,
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
          child: SizedBox(
            height: 46,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = (constraints.maxHeight.isFinite &&
                        constraints.maxHeight > 0)
                    ? constraints.maxHeight
                    : 46.0;
                return ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: h,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: constraints.maxWidth),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < menuList.length; i++) ...[
                                itemBuilder(menuList[i], i),
                                if (i != menuList.length - 1)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
