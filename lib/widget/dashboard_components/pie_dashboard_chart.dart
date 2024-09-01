import 'package:flutter/material.dart';

import '../pie_chart_model.dart';
import 'pie_chart.dart';

class PieDashboardChart extends StatefulWidget {
  final List<PieChartModel> dataList;

  const PieDashboardChart({super.key, required this.dataList});

  @override
  State<PieDashboardChart> createState() => _PieDashboardChartState();
}

class _PieDashboardChartState extends State<PieDashboardChart> {
  List<PieChartModel> dataList = [];
  @override
  Widget build(BuildContext context) {
    dataList = widget.dataList;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
          ),
          PieChartComponent(
            // height: 300,
            dataList: dataList,
          ),
        ],
      ),
    );
  }
}
