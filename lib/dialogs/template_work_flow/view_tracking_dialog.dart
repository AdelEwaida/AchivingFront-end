import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/db/department_models/department_model.dart';
import '../../models/db/work_flow/tracking_step_info_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/department_controller/department_cotnroller.dart';
import '../app_dialog.dart';

class ViewTrackingDialog extends StatefulWidget {
  final String documentKey;
  const ViewTrackingDialog({super.key, required this.documentKey});

  @override
  State<ViewTrackingDialog> createState() => _ViewTrackingDialogState();
}

class _ViewTrackingDialogState extends State<ViewTrackingDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  bool isLoading = true;

  List<TrackingResponseModel> trackingList = [];
  final WorkFlowTemplateContoller _controller = WorkFlowTemplateContoller();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    _loadDept();
  }

  Future<void> _loadDept() async {
    final results = await Future.wait([
      _controller.getTrackingByDocument(widget.documentKey),
      DepartmentController().getDep(SearchModel(page: 1)),
    ]);

    if (!mounted) return;

    final tracking = results[0] as List<TrackingResponseModel>;
    final depts = results[1] as List<DepartmentModel>;

    final map = <String, String>{};
    for (final d in depts) {
      if (d.txtKey != null && d.txtKey!.isNotEmpty) {
        final name =
            (d.txtDescription != null && d.txtDescription!.trim().isNotEmpty)
                ? d.txtDescription!.trim()
                : (d.txtShortcode != null && d.txtShortcode!.trim().isNotEmpty)
                    ? d.txtShortcode!.trim()
                    : d.txtKey!;
        map[d.txtKey!] = name;
      }
    }

    setState(() {
      trackingList = tracking;
      _deptMap = map;
      isLoading = false;
    });
  }

  Map<String, String> _deptMap = {};

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    return AppDialog(
      width: isDesktop ? width * 0.6 : width * 0.96,
      height: isDesktop ? height * 0.85 : height * 0.85,
      title: _locale.viewTracking,
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trackingList.isEmpty
              ? Center(
                  child: Text(
                    _locale.noData,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                )
              : _buildContent(),
      actions: [
        Center(
          child: CustomElevatedButton(
            text: _locale.cancel,
            color: redColor,
            icon: Icons.close,
            width: isDesktop ? width * 0.1 : width * 0.4,
            height: height * 0.048,
            fontSize: 15,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      itemCount: trackingList.length,
      itemBuilder: (context, index) {
        final item = trackingList[index];
        return _buildTrackingCard(item);
      },
    );
  }

  Widget _buildTrackingCard(TrackingResponseModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tracking header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded,
                    color: Color(0xFF185FA5), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.tracking?.txtNotes ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2340),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // _buildTrackingStatusChip(item.tracking?.intStatus),
              ],
            ),
          ),

          // Meta row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  item.tracking?.txtCreatedBy ?? "",
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.tracking?.datCreatedAt),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Steps
          if (item.steps != null && item.steps!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children:
                    item.steps!.map((step) => _buildStepCard(step)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepCard(TrackingStepInfoModel step) {
    final statusInfo = _stepStatusInfo(step.intStatus);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number bubble
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${step.intStepOrder ?? ''}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF185FA5),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.txtStepDescription ?? "",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2340),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStepStatusChip(statusInfo),
                  ],
                ),
                const SizedBox(height: 6),

                // Dept code
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined,
                        size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _deptMap[step.txtDeptcode] ?? step.txtDeptcode ?? "",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),

                // Received by
                if (step.txtReceivedBy != null &&
                    step.txtReceivedBy!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.download_done_rounded,
                          size: 12, color: Color(0xFF0D9B8A)),
                      const SizedBox(width: 4),
                      Text(
                        "${_locale.receivedBy}: ${step.txtReceivedBy}",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF0D9B8A)),
                      ),
                      if (step.datReceivedAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(step.datReceivedAt),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                ],

                // Sent by
                if (step.txtSentBy != null && step.txtSentBy!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.send_rounded,
                          size: 12, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 4),
                      Text(
                        "${_locale.sentBy}: ${step.txtSentBy}",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF7C3AED)),
                      ),
                      if (step.datSentAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(step.datSentAt),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                ],

                // Notes
                if (step.txtNotes != null && step.txtNotes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.notes_rounded,
                          size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          step.txtNotes!,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatusChip(int? status) {
    Color color;
    String label;
    switch (status) {
      case 0:
        color = Colors.grey;
        label = _locale.trackingStatusPending;
        break;
      case 1:
        color = Colors.orange;
        label = _locale.trackingStatusInProgress;
        break;
      case 2:
        color = Colors.green;
        label = _locale.trackingStatusCompleted;
        break;
      default:
        color = Colors.grey;
        label = "";
    }
    return _chip(label, color);
  }

  _StepStatusInfo _stepStatusInfo(int? status) {
    switch (status) {
      case 0:
        return _StepStatusInfo(Colors.grey, _locale.stepStatusNone);
      case 1:
        return _StepStatusInfo(Colors.orange, _locale.stepStatusPending);
      case 2:
        return _StepStatusInfo(Colors.blue, _locale.stepStatusReceived);
      case 3:
        return _StepStatusInfo(Colors.green, _locale.stepStatusSent);
      default:
        return _StepStatusInfo(Colors.grey, "");
    }
  }

  Widget _buildStepStatusChip(_StepStatusInfo info) {
    return _chip(info.label, info.color);
  }

  Widget _chip(String label, Color color) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return "";
    try {
      final dt = DateTime.parse(raw);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

class _StepStatusInfo {
  final Color color;
  final String label;
  const _StepStatusInfo(this.color, this.label);
}
