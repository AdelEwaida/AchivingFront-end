import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  int touchedIndex = -1;
  int duration = 100;

  double radiusNormal = 130;
  double radiusHover = 140;

  double width = 500;
  double height = 500;

  Color borderColor = Colors.white;
  bool isMobile = false;
  bool isLoading = false;
  Widget buildWidget = const Row();

  @override
  void didChangeDependencies() {
    // getBuildWidget();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    setAttributes();

    super.initState();
  }

  getBuildWidget() {
    List<PieChartModel> dataList = widget.dataList;
    bool isEmpty = dataList.isEmpty ? true : false;
    setState(() {
      isLoading = true;
    });

    buildWidget = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: width,
          height: isMobile ? 280 : 250,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 1,
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: isEmpty ? noDataList() : showList(dataList),
            ),
            swapAnimationDuration: Duration(milliseconds: duration),
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
                children: showIndicators(dataList),
              ),
            ),
          ),
        ),
      ],
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    isMobile = Responsive.isMobile(context);
    radiusNormal = isMobile ? 120 : 120;
    radiusHover = isMobile ? 130 : 110;
    getBuildWidget();
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : buildWidget;
  }

  List<PieChartSectionData> showList(List<PieChartModel> dataList) {
    return List.generate(dataList.length, (i) {
      bool isTouched = i == touchedIndex;
      final radius = isTouched ? radiusHover : radiusNormal;
      PieChartModel data = dataList[i];
      return PieChartSectionData(
        value: data.value,
        title: "${data.title}\n${Converters.formatNumber(data.value!)}",
        color: data.color,
        radius: radius,
        titleStyle: TextStyle(color: Colors.white, fontSize: isMobile ? 9 : 15),
        borderSide: isTouched
            ? BorderSide(
                color: borderColor,
                strokeAlign: 10,
                width: 5,
              )
            : null,
        // badgeWidget: Responsive.isDesktop(context) ? badgeLabel(data) : null,
        badgePositionPercentageOffset: 2,
      );
    });
  }

  Padding badgeLabel(PieChartModel data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black38,
            ),
          ],
        ),
        child: Text(
          data.title ?? "NONE",
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 9 : 15),
        ),
      ),
    );
  }

  List<PieChartSectionData> noDataList() {
    PieChartModel data = PieChartModel(
      value: 100,
      title: "NO DATA",
      color: Colors.blue,
    );

    List<PieChartSectionData> noData = [
      PieChartSectionData(
        value: data.value,
        title: data.title,
        color: data.color,
        radius: radiusNormal,
        titleStyle: const TextStyle(color: Colors.white),
      ),
    ];

    return noData;
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
          textSize: isMobile ? 9 : 16,
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

    if (widget.radiusNormal != null) {
      radiusNormal = widget.radiusNormal!;
    }
    if (widget.radiusHover != null) {
      radiusHover = widget.radiusHover!;
    }
  }
}
