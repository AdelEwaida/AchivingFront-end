import 'dart:async';
import 'package:flutter/material.dart';
import '../models/db/work_flow/user_step_request_body.dart';
import '../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'notification_list_mapper.dart';

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  WorkFlowTemplateContoller workFlowTemplateContoller =
      WorkFlowTemplateContoller();
  int notificationCount = 0;
  List<NotificationEntry> _notificationEntries = [];
  OverlayEntry? _overlayEntry;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
    _startPeriodicFetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  late AppLocalizations _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _fetchNotificationCount();
    });
  }

  Future<List<NotificationEntry>> _loadNotificationEntries() async {
    final entries = <NotificationEntry>[];

    try {
      final workflowResult = await workFlowTemplateContoller.getUserWorkFlowSteps(
        UserStepRequestBody(stepStatus: 0, curStep: 1),
      );
      entries.addAll(
        workflowResult.map((item) => NotificationEntry.workflow(item)),
      );
    } catch (e) {
      print('Error fetching workflow notifications: $e');
    }

    try {
      // Same source as dept approvals page — includes issueNo + barcode.
      final deptTrackingResult =
          await workFlowTemplateContoller.searchAwaitingReceive();
      entries.addAll(
        deptTrackingResult.map((item) => NotificationEntry.deptTracking(item)),
      );
    } catch (e) {
      print('Error fetching dept tracking notifications: $e');
    }

    return entries;
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final entries = await _loadNotificationEntries();
      if (!mounted) return;
      setState(() {
        notificationCount = entries.length;
      });
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<void> _fetchNotificationList() async {
    try {
      final entries = await _loadNotificationEntries();
      if (!mounted) return;
      setState(() {
        _notificationEntries = entries;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void _toggleNotificationList() async {
    if (_overlayEntry == null) {
      await _fetchNotificationList();
      if (!mounted) return;
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            left: isRTL ? null : offset.dx,
            right: isRTL
                ? MediaQuery.of(context).size.width - (offset.dx + size.width)
                : null,
            top: offset.dy + 30,
            width: 400,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      _locale.notificationsPanel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _notificationEntries.isEmpty
                          ? Center(
                              child: Text(
                                _locale.noData,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _notificationEntries.length,
                              itemBuilder: (context, index) {
                                final entry = _notificationEntries[index];
                                final statusLabel = notificationEntryStatusLabel(
                                  entry,
                                  _locale,
                                );
                                final statusColor =
                                    notificationEntryStatusColor(entry);
                                final titleText = notificationEntryTitle(entry);

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: ListTile(
                                    leading: Icon(
                                      entry.kind ==
                                              NotificationKind.deptTrackingReceive
                                          ? Icons.account_tree_outlined
                                          : Icons.task_alt_outlined,
                                      size: 20,
                                      color: statusColor,
                                    ),
                                    title: Tooltip(
                                      message: notificationEntryTooltip(entry),
                                      child: Text(
                                        titleText,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleNotificationList,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Tooltip(
            message: _locale.notificationsPanel,
            child: Container(
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
                Icons.notifications_none_rounded,
                size: 18,
                color: Color(0xFFFFF176),
              ),
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: -2,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6F00),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 0.8,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$notificationCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
