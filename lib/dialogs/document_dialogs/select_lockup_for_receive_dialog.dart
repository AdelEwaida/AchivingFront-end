import 'package:archiving_flutter_project/dialogs/app_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/custom_drop_down.dart';

Future<String?> showSelectLockupForReceiveDialog(
  BuildContext context, {
  String? dialogTitle,
}) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _SelectLockupForReceiveDialog(dialogTitle: dialogTitle),
  );
}

class _SelectLockupForReceiveDialog extends StatefulWidget {
  const _SelectLockupForReceiveDialog({this.dialogTitle});

  final String? dialogTitle;

  @override
  State<_SelectLockupForReceiveDialog> createState() =>
      _SelectLockupForReceiveDialogState();
}

class _SelectLockupForReceiveDialogState
    extends State<_SelectLockupForReceiveDialog> {
  final DepartmentController _controller = DepartmentController();
  bool _loading = true;
  List<DepartmentModel> _items = [];
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await _controller.getDep(SearchModel(page: 1));
    if (!mounted) return;
    final byKey = <String, DepartmentModel>{};
    for (final e in raw) {
      final key = (e.txtKey ?? '').trim();
      if (key.isEmpty) continue;
      byKey[key] = e;
    }
    final list = byKey.values.toList()
      ..sort((a, b) {
        final an = (a.txtDescription ?? '').trim().toLowerCase();
        final bn = (b.txtDescription ?? '').trim().toLowerCase();
        return an.compareTo(bn);
      });
    setState(() {
      _items = list;
      _selectedKey = list.isEmpty ? null : list.first.txtKey!.trim();
      _loading = false;
    });
  }

  String _rowLabel(DepartmentModel e) {
    final name = (e.txtDescription ?? '').trim();
    if (name.isNotEmpty) return name;
    return (e.txtKey ?? '').trim();
  }

  bool get _canConfirm =>
      !_loading && _items.isNotEmpty && (_selectedKey?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return AppDialog(
      title: widget.dialogTitle ?? l10n.deptTrackingReceiveLockupTitle,
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
                    l10n.noData,
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
                    bordeText: l10n.department,
                    initialValue: _items.firstWhere(
                      (e) => e.txtKey?.trim() == _selectedKey,
                      orElse: () => _items.first,
                    ),
                    items: _items,
                    selectedVal: () {
                      final match = _items
                          .where((e) => e.txtKey?.trim() == _selectedKey);
                      if (match.isEmpty) return null;
                      return _rowLabel(match.first);
                    }(),
                    noDataString: l10n.noData,
                    onChanged: (value) {
                      if (value is DepartmentModel) {
                        setState(() {
                          _selectedKey = value.txtKey?.trim();
                        });
                      }
                    },
                  ),
                ),
      actions: [
        CustomElevatedButton(
          text: l10n.close,
          color: redColor,
          icon: Icons.close_rounded,
          width: 100,
          height: 40,
          fontSize: 14,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        SizedBox(width: 10),
        CustomElevatedButton(
          text: l10n.ok,
          color: greenColor,
          width: 100,
          height: 40,
          fontSize: 14,
          onPressed: () {
            if (!_canConfirm) return;
            Navigator.of(context).pop(_selectedKey!.trim());
          },
        ),
      ],
    );
  }
}
