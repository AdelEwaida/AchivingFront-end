import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/func/responsive.dart';
import '../charts.dart';

class BarDashboardChart extends StatefulWidget {
  final List<BarData> barChartData;
  final bool isMax;
  final Color accentColor;

  const BarDashboardChart({
    super.key,
    required this.barChartData,
    required this.isMax,
    this.accentColor = const Color(0xFF185FA5),
  });

  @override
  State<BarDashboardChart> createState() => _BarDashboardChartState();
}

class _BarDashboardChartState extends State<BarDashboardChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(BarDashboardChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.barChartData != widget.barChartData) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Medal colors for top 3 ───────────────────────────────────
  Color _rankColor(int index) {
    if (index == 0) return const Color(0xFFFFD700); // gold
    if (index == 1) return const Color(0xFFB0B7C3); // silver
    if (index == 2) return const Color(0xFFCD7F32); // bronze
    return widget.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    late AppLocalizations locale = AppLocalizations.of(context)!;

    if (widget.barChartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              locale.nodataSelected,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    final sorted = [...widget.barChartData]
      ..sort((a, b) => (b.percent ?? 0).compareTo(a.percent ?? 0));
    final double maxVal = sorted.first.percent ?? 1;
    final double total = sorted.fold(0.0, (sum, e) => sum + (e.percent ?? 0));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Opacity(
        opacity: _animation.value,
        child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final item = sorted[index];
          final double val = item.percent ?? 0;
          final double percentage = total > 0 ? (val / total * 100) : 0;
          final double barRatio = maxVal > 0 ? val / maxVal : 0;
          final Color rankColor = _rankColor(index);
          final bool isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isHovered
                    ? widget.accentColor.withOpacity(0.04)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // ── Rank badge ───────────────────────────────
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: rankColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: rankColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Category name ────────────────────────────
                  SizedBox(
                    width: isMobile ? 60 : 100,
                    child: Text(
                      item.name ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isHovered
                            ? widget.accentColor
                            : const Color(0xFF3D3D3A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Animated progress bar ────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        // Track
                        Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        // Fill
                        LayoutBuilder(
                          builder: (context, bc) => Container(
                            height: 22,
                            width: bc.maxWidth * barRatio * _animation.value,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.accentColor.withOpacity(0.6),
                                  widget.accentColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        // Percentage label inside bar
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFB0B7C3),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Value ────────────────────────────────────
                  SizedBox(
                    width: isMobile ? 36 : 48,
                    child: Text(
                      val.toInt().toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.accentColor,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}
