import 'package:archiving_flutter_project/dialogs/app_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/custom_drop_down.dart';

class DeptTrackingSendRequest {
  DeptTrackingSendRequest({
    required this.deptCode,
    required this.notes,
  });

  final String deptCode;
  final String notes;
}

Future<DeptTrackingSendRequest?> showDeptTrackingSendDialog(
  BuildContext context, {
  required String defaultDeptCode,
  required String defaultDeptName,
  String initialNotes = '',
}) {
  return showDialog<DeptTrackingSendRequest>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _DeptTrackingSendDialog(
      defaultDeptCode: defaultDeptCode,
      defaultDeptName: defaultDeptName,
      initialNotes: initialNotes,
    ),
  );
}

class _DeptTrackingSendDialog extends StatefulWidget {
  const _DeptTrackingSendDialog({
    required this.defaultDeptCode,
    required this.defaultDeptName,
    this.initialNotes = '',
  });

  final String defaultDeptCode;
  final String defaultDeptName;
  final String initialNotes;

  @override
  State<_DeptTrackingSendDialog> createState() =>
      _DeptTrackingSendDialogState();
}

class _DeptTrackingSendDialogState extends State<_DeptTrackingSendDialog> {
  final DepartmentController _controller = DepartmentController();

  late final TextEditingController _notesController;
  late bool _useDefaultDept;

  bool _loadingDepts = false;
  List<DepartmentModel> _departments = [];
  String? _selectedDeptKey;

  bool get _hasDefaultNext => widget.defaultDeptCode.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
    _useDefaultDept = _hasDefaultNext;
    _loadDepartments();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    if (_loadingDepts || _departments.isNotEmpty) return;

    setState(() => _loadingDepts = true);

    final list = await _controller.getAllDepartmentsFromApi();
    if (!mounted) return;

    final defaultKey = widget.defaultDeptCode.trim();
    String? selectedKey;
    if (defaultKey.isNotEmpty &&
        list.any((e) => e.txtKey?.trim() == defaultKey)) {
      selectedKey = defaultKey;
    } else if (list.isNotEmpty) {
      selectedKey = list.first.txtKey!.trim();
    }

    setState(() {
      _departments = list;
      _selectedDeptKey = selectedKey;
      _loadingDepts = false;
    });
  }

  DepartmentModel? get _selectedDept {
    if (_selectedDeptKey == null) return null;
    for (final e in _departments) {
      if (e.txtKey?.trim() == _selectedDeptKey) return e;
    }
    return null;
  }

  void _chooseOtherDept() {
    setState(() => _useDefaultDept = false);
  }

  void _confirm() {
    final deptCode = _useDefaultDept && _hasDefaultNext
        ? widget.defaultDeptCode.trim()
        : (_selectedDeptKey ?? '').trim();
    if (deptCode.isEmpty) return;

    Navigator.of(context).pop(
      DeptTrackingSendRequest(
        deptCode: deptCode,
        notes: _notesController.text.trim(),
      ),
    );
  }

  Widget _deptDropdown(AppLocalizations l10n) {
    if (_loadingDepts) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_departments.isEmpty) {
      return Text(
        l10n.noData,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
      );
    }

    final selected = _selectedDept ?? _departments.first;

    return DropDown(
      key: ValueKey('dept-picker-${_departments.length}'),
      width: double.infinity,
      height: 50,
      heightVal: MediaQuery.of(context).size.height * 0.45,
      searchBox: true,
      bordeText: l10n.department,
      initialValue: selected,
      items: _departments,
      noDataString: l10n.noData,
      onChanged: (value) {
        if (value is DepartmentModel) {
          setState(() => _selectedDeptKey = value.txtKey?.trim());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final nextName = widget.defaultDeptName.trim().isEmpty
        ? widget.defaultDeptCode.trim()
        : widget.defaultDeptName.trim();
    final showDeptPicker = !_useDefaultDept || !_hasDefaultNext;

    return AppDialog(
      title: l10n.deptTrackingSendOnly,
      width: size.width * 0.52,
      height: size.height * 0.74,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   _hasDefaultNext
            //       ? l10n.deptTrackingSendNextDeptMessage(nextName)
            //       : l10n.deptTrackingSendDeptTitle,
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(fontSize: 14, height: 1.4),
            // ),
            // const SizedBox(height: 20),
            if (_hasDefaultNext)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _useDefaultDept = true),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _useDefaultDept,
                              onChanged: (v) =>
                                  setState(() => _useDefaultDept = true),
                            ),
                            Expanded(
                              child: Text(
                                l10n.deptTrackingSendToNextDept,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _chooseOtherDept,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: false,
                              groupValue: _useDefaultDept,
                              onChanged: (v) => _chooseOtherDept(),
                            ),
                            Expanded(
                              child: Text(
                                l10n.deptTrackingSendChooseOtherDept,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (showDeptPicker) ...[
              const SizedBox(height: 12),
              _deptDropdown(l10n),
            ],
            const SizedBox(height: 20),
            Text(
              l10n.deptTrackingSendNotesLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.deptTrackingSendNotesHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          text: l10n.close,
          color: redColor,
          icon: Icons.close_rounded,
          width: 110,
          height: 40,
          fontSize: 14,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
        CustomElevatedButton(
          text: l10n.deptTrackingSendOnly,
          color: const Color(0xFF1565C0),
          icon: Icons.send_rounded,
          width: 110,
          height: 40,
          fontSize: 14,
          onPressed: _confirm,
        ),
      ],
    );
  }
}
