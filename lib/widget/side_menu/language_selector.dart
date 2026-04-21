import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/local_provider.dart';
import '../../utils/constants/colors.dart';
import '../language_widget/circle_flags.dart';


class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currentCode = context.watch<LocaleProvider>().locale.languageCode;

    return Tooltip(
      message: currentCode == 'ar' ? 'Arabic' : 'English',
      child: GestureDetector(
        onTapDown: (details) =>
            _showLanguageMenu(context, details, currentCode),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 0.8,
        ),
      ),
      child: const Icon(
        Icons.language_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Future<void> _showLanguageMenu(
    BuildContext context,
    TapDownDetails details,
    String currentCode,
  ) async {
    final selected = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'language_menu',
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return Stack(
          children: [
            Positioned(
              left: details.globalPosition.dx - 120,
              top: details.globalPosition.dy + 10,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _languageItem(context, 'ar', 'AR', currentCode),
                      const SizedBox(height: 6),
                      _languageItem(context, 'en', 'EN', currentCode),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.08),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              alignment: Alignment.topRight,
              child: child,
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    final newLocale = Locale(selected);
    context.read<LocaleProvider>().setLocale(newLocale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', selected);
  }

  Widget _languageItem(
    BuildContext context,
    String value,
    String label,
    String currentCode,
  ) {
    final isSelected = value == currentCode;
    final flagCode = value == 'ar' ? 'ps' : 'us';

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).pop(value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 15,
              color: isSelected ? textSecondary : Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 8),
            CircleFlag(flagCode, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
