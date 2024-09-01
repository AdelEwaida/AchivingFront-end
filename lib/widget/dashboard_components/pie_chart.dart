import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../utils/func/converters.dart';
import '../../utils/func/responsive.dart';
import '../pie_chart_model.dart';
import 'custom_scroll_behavior.dart';
import 'indicator.dart';

class PieChartComponent extends StatefulWidget {
  final double? width;
  final double? height;
  final List<PieChartModel> dataList;
  final double? radiusNormal;
  final double? radiusHover;

  const PieChartComponent({
    super.key,
    required this.dataList,
    this.width,
    this.height,
    this.radiusNormal,
    this.radiusHover,
  });

  @override
  State<PieChartComponent> createState() => _PieChartComponentState();
}

class _PieChartComponentState extends State<PieChartComponent> {
  double width = 500;
  double height = 500;

  bool isMobile = false;
  bool isLoading = false;

  @override
  void initState() {
    setAttributes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isMobile = Responsive.isMobile(context);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : buildPieChart();
  }

  Widget buildPieChart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          height: height * 0.4,
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<PieChartModel, String>(
                dataSource: widget.dataList,
                xValueMapper: (PieChartModel data, _) => data.title ?? '',
                yValueMapper: (PieChartModel data, _) => data.value ?? 0,
                pointColorMapper: (PieChartModel data, _) =>
                    data.color ?? Colors.blue,
                dataLabelMapper: (PieChartModel data, _) =>
                    '${data.title}: ${Converters.formatNumber(data.value!)}',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  overflowMode: OverflowMode.shift,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    length: '18%', // Adjust the length as needed
                    type: ConnectorType.curve,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
          ),
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: showIndicators(widget.dataList),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> showIndicators(List<PieChartModel> dataList) {
    return List.generate(dataList.length, (i) {
      PieChartModel data = dataList[i];
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Indicator(
          color: data.color!,
          isSquare: true,
          text: "${data.title!} (${Converters.formatNumber(data.value!)})",
          size: isMobile ? 9 : 16,
          textSize: isMobile ? 9 : 12,
        ),
      );
    });
  }

  void setAttributes() {
    if (widget.width != null) {
      width = widget.width!;
    }
    if (widget.height != null) {
      height = widget.height!;
    }
  }
}
