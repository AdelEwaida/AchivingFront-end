import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class AppDialog extends StatefulWidget {
  final Object title;
  final Widget content;
  final List<Widget>? actions;

  final double? width;
  final double? height;

  static const double _radius = 18;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.width,
    this.height,
  });

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(curved);
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1).animate(curved);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: widget.width ?? size.width * 0.4,
            constraints: BoxConstraints(
              maxHeight: widget.height ?? size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDialog._radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDialog._radius),
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 123, 93, 48),
                      Color(0xFF8A6528),
                      Color(0xFFB3873D),
                      Color(0xFFC9A24F),
                      Color(0xFFd5b166),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTitle(),
                    ),
                    _HoverCloseButton(
                      onTap: () => Navigator.pop(context),
                      tooltip: local?.cancel ?? "",
                    ),
                  ],
                ),
              ),

              // CONTENT
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.content,
                ),
              ),

              // ACTIONS
              if (widget.actions != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                    left: 12,
                    right: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.actions!,
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

  Widget _buildTitle() {
    if (widget.title is Widget) {
      return widget.title as Widget;
    }
    return Text(
      widget.title.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class _HoverCloseButton extends StatefulWidget {
  final VoidCallback onTap;
  final String tooltip;

  const _HoverCloseButton({required this.onTap, required this.tooltip});

  @override
  State<_HoverCloseButton> createState() => _HoverCloseButtonState();
}

class _HoverCloseButtonState extends State<_HoverCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.07 : 1,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(_isHovered ? 0.52 : 0.42),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(_isHovered ? 1 : 0.95),
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
