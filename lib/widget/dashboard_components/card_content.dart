import 'package:flutter/material.dart';
import '../../utils/func/responsive.dart';

class CardContent extends StatefulWidget {
  final String title;
  final String value;
  final String? dates;
  final String? trendLabel;
  final bool? trendUp;
  final IconData icon;
  final Color accentColor;

  const CardContent({
    super.key,
    required this.title,
    required this.value,
    this.dates,
    this.trendLabel,
    this.trendUp,
    required this.icon,
    this.accentColor = const Color(0xFF185FA5),
  });

  @override
  State<CardContent> createState() => _CardContentState();
}

class _CardContentState extends State<CardContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final Color accent = widget.accentColor;
    final Color iconBg = accent.withOpacity(0.10);
    final bool hasTrend = widget.trendLabel != null;
    final bool trendUp = widget.trendUp ?? true;
    final Color trendColor =
        trendUp ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D);
    final Color trendBg =
        trendUp ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 16,
          vertical: isMobile ? 8 : 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Header row: title + optional date ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.dates != null && widget.dates!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      widget.dates!,
                      style: TextStyle(
                        fontSize: 10,
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Value + Icon row ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  width: isMobile ? 36 : 44,
                  height: isMobile ? 36 : 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: accent,
                    size: isMobile ? 18 : 22,
                  ),
                ),
              ],
            ),

            // ── Trend badge ─────────────────────────────────────────────
            if (hasTrend)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 13,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.trendLabel!,
                      style: TextStyle(
                        fontSize: 11,
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
