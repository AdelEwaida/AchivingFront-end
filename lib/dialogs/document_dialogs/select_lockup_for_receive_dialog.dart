import 'package:archiving_flutter_project/dialogs/app_dialog.dart';
import 'package:archiving_flutter_project/models/db/work_flow/lockup_location_model.dart';
import 'package:archiving_flutter_project/service/controller/lockup_location_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/custom_drop_down.dart';

Future<String?> showSelectLockupForReceiveDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _SelectLockupForReceiveDialog(),
  );
}

class _SelectLockupForReceiveDialog extends StatefulWidget {
  const _SelectLockupForReceiveDialog();

  @override
  State<_SelectLockupForReceiveDialog> createState() =>
      _SelectLockupForReceiveDialogState();
}

class _SelectLockupForReceiveDialogState
    extends State<_SelectLockupForReceiveDialog> {
  final LockupLocationController _controller = LockupLocationController();
  bool _loading = true;
  List<LockupLocationModel> _items = [];
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await _controller.getAllLockupLocations();
    if (!mounted) return;
    final byCode = <String, LockupLocationModel>{};
    for (final e in raw) {
      final c = (e.lockupCode ?? '').trim();
      if (c.isEmpty) continue;
      byCode[c] = e;
    }
    final list = byCode.values.toList()
      ..sort((a, b) {
        final an = (a.name ?? '').trim().toLowerCase();
        final bn = (b.name ?? '').trim().toLowerCase();
        final c = an.compareTo(bn);
        if (c != 0) return c;
        return (a.lockupCode ?? '').compareTo(b.lockupCode ?? '');
      });
    setState(() {
      _items = list;
      _selectedCode = list.isEmpty ? null : list.first.lockupCode!.trim();
      _loading = false;
    });
  }

  String _rowLabel(LockupLocationModel e) {
    final name = (e.name ?? '').trim();
    final code = (e.lockupCode ?? '').trim();
    if (name.isEmpty) return code;
    return '$name ($code)';
  }

  bool get _canConfirm =>
      !_loading && _items.isNotEmpty && (_selectedCode?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return AppDialog(
      title: l10n.deptTrackingReceiveLockupTitle,
      width: size.width * 0.42,
      height: size.height * 0.38,
      content: _loading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : _items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    l10n.deptTrackingReceiveNoLockups,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, height: 1.35),
                  ),
                )
              : Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: DropDown(
                    width: double.infinity,
                    height: 50,
                    searchBox: true,
                    bordeText: l10n.deptTrackingReceiveLockupLabel,
                    initialValue: _items.firstWhere(
                      (e) => e.lockupCode?.trim() == _selectedCode,
                      orElse: () => _items.first,
                    ),
                    items: _items,
                    selectedVal: _items
                        .where((e) => e.lockupCode?.trim() == _selectedCode)
                        .map((e) => _rowLabel(e))
                        .firstOrNull,
                    noDataString: l10n.noData,
                    onChanged: (value) {
                      if (value is LockupLocationModel) {
                        setState(() {
                          _selectedCode = value.lockupCode?.trim();
                        });
                      }
                    },
                  ),
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        CustomElevatedButton(
          text: l10n.ok,
          color: greenColor,
          width: 100,
          height: 40,
          fontSize: 14,
          onPressed: () {
            if (!_canConfirm) return;
            Navigator.of(context).pop(_selectedCode!.trim());
          },
        ),
      ],
    );
  }
}
