import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../utils/func/responsive.dart';

class LineDashboardChart extends StatefulWidget {
  final List<double> balances;
  final List<String> periods;
  final bool isMax;
  const LineDashboardChart(
      {super.key,
      required this.balances,
      required this.periods,
      required this.isMax});
  @override
  State<LineDashboardChart> createState() => _LineDashboardChartState();
}

class _LineDashboardChartState extends State<LineDashboardChart> {
  List<double> balances = [];
  List<String> periods = [];
  bool isShowingMainData = false;
  bool isLoading = false;
  Widget buildWidget = const Row();
  LineChartData get sampleData2 => LineChartData(
      lineTouchData: lineTouchData2,
      gridData: gridData,
      titlesData: titlesData2,
      borderData: borderData,
      lineBarsData: lineBarsData2,
      baselineY: 1);
  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: true,
      );
  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: topTitles,
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles,
        ),
      );
  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
      ];
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 14,
    );
    String text;
    text = value.ceil().toString();
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles get leftTitles => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: balances.isEmpty ? 300000 : getMax() / 5,
        reservedSize: 100,
      );
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 14,
    );
    int index = value.round();
    Widget text =
        Text(periods.isNotEmpty ? periods[index] : 0.toString(), style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget topTitleWidgets(double value, TitleMeta meta) {
    return const Text("");
  }

  SideTitles get topTitles => SideTitles(
        getTitlesWidget: topTitleWidgets,
        showTitles: true,
        interval: balances.isEmpty ? 300000 : getMax() / 5,
        reservedSize: 35,
      );
  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );
  FlGridData get gridData => const FlGridData(show: true);
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: primary.withOpacity(0.2), width: 4),
          left: BorderSide(color: primary.withOpacity(0.2), width: 4),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );
  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: Color.fromARGB(255, 3, 18, 97).withOpacity(1),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
              colors: [Colors.grey.shade300, Colors.green.shade200])),
      spots: getSpots());
  List<FlSpot> getSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < balances.length; i++) {
      spots.add(FlSpot(i * 1.0, balances[i]));
    }
    return spots;
  }

  double width = 0;
  double height = 0;
  final ScrollController _scrollController = ScrollController();
  @override
  void didChangeDependencies() {
    // getBuildWidget();
    super.didChangeDependencies();
  }

  getBuildWidget() {
    setState(() {
      isLoading = true;
    });
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    balances = widget.balances;
    periods = widget.periods;
    bool isMobile = Responsive.isMobile(context);
    buildWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8,
          trackVisibility: true,
          radius: const Radius.circular(4),
          child: Padding(
            padding:
                const EdgeInsets.only(right: 50, bottom: 15, top: 15, left: 0),
            child: SizedBox(
                width: isMobile
                    ? (widget.isMax && periods.length < 6) || periods.length < 6
                        ? width * 0.8
                        : width * (periods.length / 4)
                    : (widget.isMax && periods.length < 6) || periods.length < 6
                        ? width * 0.6
                        : width * (periods.length / 8),
                child: LineChart(
                  sampleData2,
                  // duration: const Duration(milliseconds: 250),
                )),
          )),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    balances = widget.balances;
    periods = widget.periods;
    bool isMobile = Responsive.isMobile(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8,
          trackVisibility: true,
          radius: const Radius.circular(4),
          child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 50, bottom: 15, top: 15, left: 0),
                child: SizedBox(
                    width: isMobile
                        ? (widget.isMax && periods.length < 6) ||
                                periods.length < 6
                            ? width * 0.8
                            : width * (periods.length / 4)
                        : (widget.isMax && periods.length < 6) ||
                                periods.length < 6
                            ? width * 0.6
                            : width * (periods.length / 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0)),
                        Expanded(
                            child: LineChart(
                          sampleData2,
                          duration: const Duration(milliseconds: 250),
                        )),
                      ],
                    )),
              ))),
    );
  }

  double getMax() {
    double max = 0;
    for (int i = 0; i < balances.length; i++) {
      if (balances[i] > max) {
        max = balances[i];
      }
    }
    return max;
  }
}
