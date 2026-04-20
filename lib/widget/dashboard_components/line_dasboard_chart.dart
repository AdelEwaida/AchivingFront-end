import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../utils/func/responsive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LineDashboardChart extends StatefulWidget {
  final List<double> balances;
  final List<String> periods;
  final bool isMax;

  const LineDashboardChart({
    super.key,
    required this.balances,
    required this.periods,
    required this.isMax,
  });

  @override
  State<LineDashboardChart> createState() => _LineDashboardChartState();
}

class _LineDashboardChartState extends State<LineDashboardChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  int _touchedIndex = -1;
  final ScrollController _scrollController = ScrollController();
  late AppLocalizations _locale;

  // ── Color palette ───────────────────────────────────────────────
  static const Color _lineColor = Color(0xFF185FA5);
  static const Color _gradientTop = Color(0x44185FA5);
  static const Color _gradientBottom = Color(0x00185FA5);
  static const Color _dotColor = Color(0xFF185FA5);
  static const Color _tooltipBg = Color(0xFF1A2340);
  static const Color _gridColor = Color(0xFFEEF2F7);
  static const Color _borderColor = Color(0xFFDDE3EE);
  static const Color _labelColor = Color(0xFF8A94A6);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    _animController.forward();
  }

  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(LineDashboardChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balances != widget.balances) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────
  double _getMax() {
    if (widget.balances.isEmpty) return 1;
    return widget.balances.reduce((a, b) => a > b ? a : b);
  }

// 2. Spots — divide x by 0.3 to pack points closer together
  List<FlSpot> _getSpots() {
    return List.generate(
      widget.balances.length,
      (i) => FlSpot(i * 0.3, widget.balances[i]), // 0.3 instead of 1.0
    );
  }

  // ── Touch data ──────────────────────────────────────────────────
  LineTouchData get _lineTouchData => LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchCallback: (event, response) {
          final newIndex = response?.lineBarSpots?.first.spotIndex ?? -1;
          if (newIndex != _touchedIndex) {
            // ← only rebuild if changed
            setState(() {
              _touchedIndex = newIndex;
            });
          }
        },
        // 3. Tooltip — bigger padding and font sizes
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: _tooltipBg,
          tooltipRoundedRadius: 12,
          showOnTopOfTheChartBoxArea: true,
          tooltipMargin: 12,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (spots) => spots.map((spot) {
            final i = (spot.x / 0.3).round();
            final name = i < widget.periods.length ? widget.periods[i] : '';
            return LineTooltipItem(
              '$name\n',
              const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: spot.y.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );

  // ── Titles ──────────────────────────────────────────────────────
  FlTitlesData get _titlesData => FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            interval: _getMax() < 5 ? 1 : (_getMax() / 4).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              if (value == meta.max) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(1)}k'
                      : value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: _labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 0.3, // match the spot x spacing
            getTitlesWidget: (value, meta) {
              final i = (value / 0.3).round();
              if (i < 0 || i >= widget.periods.length) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  widget.periods[i],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: _labelColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      );

  // ── Grid ────────────────────────────────────────────────────────
  FlGridData get _gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getMax() < 5 ? 1 : (_getMax() / 4).ceilToDouble(),
        getDrawingHorizontalLine: (_) => FlLine(
          color: _gridColor,
          strokeWidth: 1,
          dashArray: [6, 4],
        ),
      );

  // ── Border ──────────────────────────────────────────────────────
  FlBorderData get _borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: _borderColor, width: 1),
          left: BorderSide(color: _borderColor, width: 1),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  // ── Line bar ────────────────────────────────────────────────────
  LineChartBarData get _lineBarData => LineChartBarData(
        spots: _getSpots(),
        isCurved: true,
        curveSmoothness: 0.35,
        color: _lineColor,
        barWidth: 2.5,
        isStrokeCapRound: true,
        shadow: const Shadow(
          color: Color(0x33185FA5),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
        // 1. Dots — fixed small size, no growth on touch
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) {
            return FlDotCirclePainter(
              radius: 3.5, // always 3.5, never changes
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: _dotColor,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: const LinearGradient(
            colors: [_gradientTop, _gradientBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );

  // ── Full chart data ─────────────────────────────────────────────
  LineChartData get _chartData => LineChartData(
        lineTouchData: _lineTouchData,
        gridData: _gridData,
        titlesData: _titlesData,
        borderData: _borderData,
        lineBarsData: [_lineBarData],
        minY: 0,
        maxY: _getMax() * 1.2,
        backgroundColor: Colors.transparent,
      );

  // ── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final int count = widget.periods.length;

    final double chartWidth = count < 6
        ? (isMobile ? screenWidth * 0.8 : screenWidth * 0.6)
        : screenWidth * (count / (isMobile ? 4.0 : 8.0));

    if (widget.balances.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              _locale.nodataSelected,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Opacity(
          opacity: _animation.value,
          child: child,
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: count > 6,
          trackVisibility: count > 6,
          thickness: 4,
          radius: const Radius.circular(99),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 24, bottom: 8, top: 8, left: 4),
              child: SizedBox(
                width: chartWidth,
                child: LineChart(
                  _chartData,
                  duration: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
