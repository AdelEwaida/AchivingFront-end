import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import '../app_dialog.dart';

enum TrackingType { createTracking, departmentWorkFlow }

class TrackingTypeSelectionDialog extends StatefulWidget {
  const TrackingTypeSelectionDialog({super.key});

  @override
  State<TrackingTypeSelectionDialog> createState() =>
      _TrackingTypeSelectionDialogState();
}

class _TrackingTypeSelectionDialogState
    extends State<TrackingTypeSelectionDialog> {
  TrackingType _selected = TrackingType.createTracking;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = Responsive.isDesktop(context);

    return AppDialog(
      width: isDesktop ? width * 0.36 : width * 0.92,
      height: isDesktop ? height * 0.45 : height * 0.42,
      title: locale.createTrackingDoc, // or a dedicated locale key
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _OptionTile(
              label: locale.createTrackingDoc,
              subtitle: '',
              value: TrackingType.createTracking,
              groupValue: _selected,
              onTap: () =>
                  setState(() => _selected = TrackingType.createTracking),
            ),
            const SizedBox(height: 10),
            _OptionTile(
              label: locale.departmentWorkFlow,
              subtitle: '',
              value: TrackingType.departmentWorkFlow,
              groupValue: _selected,
              onTap: () =>
                  setState(() => _selected = TrackingType.departmentWorkFlow),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
              text: locale.save, // "Continue" or your locale key
              color: primary,
              icon: Icons.arrow_forward_rounded,
              width: isDesktop ? width * 0.11 : width * 0.36,
              height: height * 0.048,
              fontSize: 15,
              onPressed: () => Navigator.pop(context, _selected),
            ),
            const SizedBox(width: 8),
            CustomElevatedButton(
              text: locale.cancel,
              color: redColor,
              icon: Icons.close,
              width: isDesktop ? width * 0.11 : width * 0.36,
              height: height * 0.048,
              fontSize: 15,
              onPressed: () => Navigator.pop(context, null),
            ),
          ],
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final TrackingType value;
  final TrackingType groupValue;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F1FB) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF185FA5) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // ← add this
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF185FA5)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF185FA5),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                // ← remove the Column, just Text
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF0C447C)
                      : const Color(0xFF1A2340),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
