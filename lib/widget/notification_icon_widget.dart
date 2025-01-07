import 'dart:async';
import 'package:flutter/material.dart';
import '../models/db/work_flow/user_work_flow_steps.dart';
import '../models/db/work_flow/work_flow_document_info.dart';
import '../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../utils/constants/colors.dart';
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
      List<UserWorkflowSteps> result =
          await workFlowTemplateContoller.getUserWorkFlowSteps();
      setState(() {
        notificationCount = result.length;
      });
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<void> _fetchNotificationList() async {
    try {
      final list = await workFlowTemplateContoller.getUserWorkFlowSteps();
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
                                message: tipsList[index].txtStepdesc,
                                child: Row(
                                  children: [
                                    // txtStepdesc Text
                                    Expanded(
                                      child: Text(
                                        tipsList[index].txtStepdesc ??
                                            'No description',
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
        children: <Widget>[
          Tooltip(
            message: _locale.approvals,
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 30.0,
              color: Colors.yellow,
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: 1,
              // top: -5,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$notificationCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
