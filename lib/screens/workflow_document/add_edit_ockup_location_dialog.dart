import 'package:archiving_flutter_project/dialogs/app_dialog.dart';

import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/db/work_flow/lockup_location_model.dart';
import '../../service/controller/lockup_location_controller.dart';

class AddEditLockupLocationDialog extends StatefulWidget {
  final LockupLocationModel? existingItem;

  const AddEditLockupLocationDialog({super.key, this.existingItem});

  @override
  State<AddEditLockupLocationDialog> createState() =>
      _AddEditLockupLocationDialogState();
}

class _AddEditLockupLocationDialogState
    extends State<AddEditLockupLocationDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  bool _saving = false;

  bool get _isEditMode => widget.existingItem != null;

  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _controller = LockupLocationController();

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _codeCtrl.text = widget.existingItem!.lockupCode ?? '';
      _nameCtrl.text = widget.existingItem!.name ?? '';
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
  }

  Future<void> _save() async {
    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (!_isEditMode && code.isEmpty) {
      CustomToastMessage.warning(context, _locale.lockupCodeRequired);
      return;
    }
    if (name.isEmpty) {
      CustomToastMessage.warning(context, _locale.nameRequired);
      return;
    }

    setState(() => _saving = true);

    if (_isEditMode) {
      // UPDATE — only send name
      final updated = widget.existingItem!.copyWith(name: name);
      final ok = await _controller.updateLockupLocation(updated);
      if (!mounted) return;
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context, true);
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    } else {
      // INSERT
      final model = LockupLocationModel(lockupCode: code, name: name);
      final error = await _controller.insertLockupLocation(model);
      if (!mounted) return;
      setState(() => _saving = false);
      if (error == null) {
        Navigator.pop(context, true);
      } else {
        CustomToastMessage.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      width: isDesktop ? width * 0.30 : width * 0.85,
      height: height * 0.34,
      title: _isEditMode ? _locale.edit : _locale.add,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lockup Code (read-only in edit mode)
            CustomTextField2(
              readOnly: _isEditMode,
              isReport: true,
              isMandetory: !_isEditMode,
              width: isDesktop ? width * 0.24 : width * 0.75,
              height: height * 0.05,
              text: Text(_locale.code),
              controller: _codeCtrl,
              onSubmitted: (_) {},
              onChanged: (_) {},
            ),
            SizedBox(height: height * 0.015),
            // Name
            CustomTextField2(
              readOnly: false,
              isReport: true,
              isMandetory: true,
              width: isDesktop ? width * 0.24 : width * 0.75,
              height: height * 0.05,
              text: Text(_locale.name),
              controller: _nameCtrl,
              onSubmitted: (_) => _save(),
              onChanged: (_) {},
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: customButtonStyle(
                context,
                Size(isDesktop ? width * 0.09 : width * 0.35, height * 0.045),
                16,
                primary,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
            ),
            SizedBox(width: width * 0.01),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              style: customButtonStyle(
                context,
                Size(isDesktop ? width * 0.09 : width * 0.35, height * 0.045),
                16,
                redColor,
              ),
              child: Text(
                _locale.cancel,
                style: const TextStyle(color: whiteColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
