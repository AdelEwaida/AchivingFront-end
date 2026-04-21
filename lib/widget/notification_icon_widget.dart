import 'dart:async';
import 'package:flutter/material.dart';
import '../models/db/work_flow/user_step_request_body.dart';
import '../models/db/work_flow/user_work_flow_steps.dart';
import '../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/func/lists.dart';

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  // final TipsService tipsService = TipsService();
  WorkFlowTemplateContoller workFlowTemplateContoller =
      WorkFlowTemplateContoller();
  int notificationCount = 0;
  List<dynamic> tipsList = [];
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
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(minutes: 3), (timer) {
      _fetchNotificationCount();
    });
  }

  Future<void> _fetchNotificationCount() async {
    try {
      List<UserWorkflowSteps> result = await workFlowTemplateContoller
          .getUserWorkFlowSteps(UserStepRequestBody(stepStatus: 0, curStep: 1));
      setState(() {
        notificationCount = result.length;
      });
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<void> _fetchNotificationList() async {
    try {
      final list = await workFlowTemplateContoller
          .getUserWorkFlowSteps(UserStepRequestBody(stepStatus: 0, curStep: 1));
      setState(() {
        tipsList = list;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void _toggleNotificationList() async {
    if (_overlayEntry == null) {
      await _fetchNotificationList();
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Determine if the layout direction is RTL (Arabic)
    bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // This GestureDetector captures taps outside the notification list
          GestureDetector(
            onTap: _removeOverlay,
            behavior: HitTestBehavior.translucent, // Ensures taps are detected
            child: Container(
              color: Colors.transparent, // Transparent container
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            left: isRTL
                ? null // For RTL, position from the right
                : offset.dx,
            right: isRTL
                ? MediaQuery.of(context).size.width - (offset.dx + size.width)
                : null, // Adjust position for RTL
            top: offset.dy + 30, // Adjust this value to position below the icon
            width: 400,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 300,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      _locale.approvals,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: tipsList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Tooltip(
                                message: tipsList[index].txtTemplateName,
                                child: Row(
                                  children: [
                                    // txtTemplateName Text
                                    Expanded(
                                      child: Text(
                                        "${tipsList[index].txtTemplateName ?? ''} - ${tipsList[index].txtDeptName ?? ''}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),

                                    // Status with orange background
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(
                                            12), // Rounded edges
                                      ),
                                      child: Text(
                                        tipsList[index].intStatus == 0
                                            ? ListConstants.getStatusName(
                                                0, _locale)!
                                            : tipsList[index].intStatus == 1
                                                ? ListConstants.getStatusName(
                                                    1, _locale)!
                                                : ListConstants.getStatusName(
                                                    2, _locale)!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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
            message: _locale.approvals,
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
                  style: TextStyle(
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
