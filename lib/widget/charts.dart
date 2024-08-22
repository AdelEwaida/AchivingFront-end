import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/screen_content_provider.dart';
import '../utils/constants/colors.dart';
import '../utils/func/converters.dart';
import '../utils/func/responsive.dart';
import 'bar_chart_data_model.dart';
import 'line_chart_data_model.dart';
import 'pie_chart_model.dart';


class BarData {
  final String? name;
  final double? percent;

  BarData({required this.name, required this.percent});
}

class CustomBarChart extends StatelessWidget {
  final List<BarData> data;
  final Color? color;
  final Color? textColor;

  const CustomBarChart({
    super.key,
    required this.data,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    ScrollController scrollController = ScrollController();
    bool isDesktop = Responsive.isDesktop(context);
    double chartHeight = isDesktop ? height * 0.37 : height * 0.5;

    return data.length > 10
        ? Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: isDesktop ? height * 0.35 : height * 0.5,
                  width: data.length * 130,
                  child: SfCartesianChart(
                    isTransposed: true,
                    primaryXAxis: CategoryAxis(
                      labelStyle: TextStyle(
                        fontSize: 13, // Set your desired font size
                      ),
                    ),
                    plotAreaBorderWidth: 0,
                    series: <ChartSeries>[
                      BarSeries<BarData, String>(
                        dataSource: data,
                        xValueMapper: (BarData value, _) => value.name,
                        yValueMapper: (BarData value, _) =>
                            double.parse(value.percent!.toStringAsFixed(2)),
                        enableTooltip: true,
                        animationDuration: 1000,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            color: textColor ?? const Color(0xFF219C90),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        pointColorMapper: (BarData value, int index) {
                          return index.isEven ? primary : secondary;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            height: chartHeight,
            child: SfCartesianChart(
              isTransposed: true,
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(
                  fontSize: 11, // Set your desired font size
                ),
              ),
              plotAreaBorderWidth: 0,
              series: <ChartSeries>[
                BarSeries<BarData, String>(
                  dataSource: data,
                  xValueMapper: (BarData value, _) => value.name,
                  yValueMapper: (BarData value, _) =>
                      double.parse(value.percent!.toStringAsFixed(2)),
                  enableTooltip: true,
                  animationDuration: 1000,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      color: textColor ?? const Color(0xFF219C90),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  pointColorMapper: (BarData value, int index) {
                    return index.isEven ? primary : secondary;
                  },
                ),
              ],
            ),
          );
  }
}

class BalanceLineChart extends StatelessWidget {
  final String xAxisText;
  final String yAxisText;
  final List<double> balances;
  final List<String> periods;

  const BalanceLineChart(
      {super.key,
      required this.balances,
      required this.periods,
      required this.xAxisText,
      required this.yAxisText});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    bool isDesktop = false;
    isDesktop = Responsive.isDesktop(context);
    List<ChartData> data = _getChartData();
    return SizedBox(
      //  height: isDesktop ? height * 0.423 : height * 0.5,

      height: isDesktop
          ? (context.read<ScreenContentProvider>().getPage() == 0
              ? height * 0.38
              : height * 0.5)
          : context.read<ScreenContentProvider>().getPage() == 0
              ? height * 0.43
              : height * 0.5,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(title: AxisTitle(text: xAxisText)),
        primaryYAxis: NumericAxis(title: AxisTitle(text: yAxisText)),
        plotAreaBorderColor: primary.withOpacity(0.2),
        plotAreaBackgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        borderWidth: 0,
        plotAreaBorderWidth: 0,
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          LineSeries<ChartData, String>(
            dataSource: data,
            animationDuration: 1000,
            xValueMapper: (ChartData value, _) => value.period,
            yValueMapper: (ChartData value, _) => value.balance,
            markerSettings: const MarkerSettings(
                color: Color(0xFF5297b0),
                borderColor: Color.fromRGBO(82, 151, 176, 1),
                isVisible: true),
            dataLabelSettings:
                const DataLabelSettings(isVisible: true, color: Colors.white),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }

  List<ChartData> _getChartData() {
    List<ChartData> data = [];
    for (int i = 0; i < balances.length; i++) {
      data.add(ChartData(periods[i], balances[i]));
    }
    return data;
  }
}

class BalancePieChart extends StatelessWidget {
  final List<PieChartModel> data;

  const BalancePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SfCircularChart(
        series: <CircularSeries>[
          PieSeries<PieChartModel, String>(
            // legendIconType: ,
            // showLegends: true,
            // pointColorMapper: (PieChartData data, _) => const Color(0xff9AA0C5),
// pointColorMapper: ,
            dataSource: data,
            xValueMapper: (PieChartModel value, _) => value.title,
            yValueMapper: (PieChartModel value, _) => value.value,
            pointColorMapper: (PieChartModel data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(
              textStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  fontSize: 13),
              labelPosition: ChartDataLabelPosition.outside,
              margin: EdgeInsets.fromLTRB(7, 7, 7, 7),
              isVisible: true,
            ),
            dataLabelMapper: (
              PieChartModel value,
              index,
            ) =>
                "${value.value}"
                "\n${getPercentage(index).toString()}% \n${value.title}",
            enableTooltip: true,
            animationDuration: 1000,
          )
        ],
      ),
    );
  }

  double getPercentage(index) {
    if (data[index].value == 0 || data[index].value == null) {
      return 0;
    } else {
      return ((data[index].value! / getSum()) * 100).roundToDouble();
    }
  }

  double getSum() {
    double sum = 0;
    for (var element in data) {
      sum += element.value!;
    }
    return sum;
  }
}

class BalanceDoubleLineChart extends StatelessWidget {
  final String xAxisText;
  final String yAxisText;
  final List<double> balances;
  final List<String> periods;
  final List<double> balances2;
  final List<String> periods2;

  const BalanceDoubleLineChart({
    Key? key,
    required this.balances,
    required this.periods,
    required this.balances2,
    required this.periods2,
    required this.xAxisText,
    required this.yAxisText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ChartData> data = _getChartData();
    List<ChartData> data2 = _getChartData2();

    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.4,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(title: AxisTitle(text: xAxisText)),
        primaryYAxis: NumericAxis(title: AxisTitle(text: yAxisText)),
        plotAreaBorderColor: Colors.transparent,
        plotAreaBackgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        borderWidth: 0,
        plotAreaBorderWidth: 0,
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          LineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData value, _) => value.period,
            yValueMapper: (ChartData value, _) => value.balance,
            markerSettings:
                const MarkerSettings(color: Color(0xff9AA0C5), isVisible: true),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
            enableTooltip: true,
            animationDuration: 1000,
            color: Colors.red,
          ),
          LineSeries<ChartData, String>(
            dataSource: data2,
            xValueMapper: (ChartData value, _) => value.period,
            yValueMapper: (ChartData value, _) => value.balance,
            markerSettings:
                const MarkerSettings(color: Color(0xff9AA0C5), isVisible: true),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
            enableTooltip: true,
            animationDuration: 1000,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  List<ChartData> _getChartData() {
    List<ChartData> data = [];
    for (int i = 0; i < balances.length; i++) {
      data.add(ChartData(periods[i], balances[i]));
    }
    return data;
  }

  List<ChartData> _getChartData2() {
    List<ChartData> data2 = [];
    for (int i = 0; i < balances2.length; i++) {
      data2.add(ChartData(periods2[i], balances2[i]));
    }
    return data2;
  }
}

class BalanceBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final Color? color;

  const BalanceBarChart({super.key, required this.data, this.color});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    ScrollController scrollController = ScrollController();
    return data.length > 10
        ? Scrollbar(
            thumbVisibility: true,
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                height: height * 0.48,
                width: data.length * 200.0,
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  isTransposed: true,
                  primaryXAxis: CategoryAxis(),
                  // primaryYAxis: NumericAxis(
                  //   minimum: 0,
                  //   maximum: double.infinity,
                  //   interval: 100,
                  // ),
                  plotAreaBorderWidth: 0,
                  series: <ChartSeries>[
                    BarSeries<BarChartData, String>(
                      dataSource: data,
                      xValueMapper: (BarChartData value, _) =>
                          "${value.category} (${Converters.formatNumber(value.value)})",
                      yValueMapper: (BarChartData value, _) => value.value,
                      enableTooltip: true,
                      animationDuration: 1000,
                      color: color ?? const Color(0xff9AA0C5),
                    )
                  ],
                ),
              ),
            ),
          )
        : Container(
            height: height * 0.48,
            padding: const EdgeInsets.all(16.0),
            child: SfCartesianChart(
              isTransposed: true,
              primaryXAxis: CategoryAxis(),
              // primaryYAxis: NumericAxis(
              //   minimum: 0,
              //   maximum: double.infinity,
              //   interval: 100,
              // ),
              plotAreaBorderWidth: 0,
              series: <ChartSeries>[
                BarSeries<BarChartData, String>(
                  dataSource: data,
                  xValueMapper: (BarChartData value, _) =>
                      "${value.category} (${Converters.formatNumber(value.value)})",
                  yValueMapper: (BarChartData value, _) => value.value,
                  enableTooltip: true,
                  animationDuration: 1000,
                  color: color ?? const Color(0xff9AA0C5),
                )
              ],
            ),
          );
  }
}

class BalanceDoubleBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final List<BarChartData> data2;
  final Color? color;

  const BalanceDoubleBarChart(
      {Key? key, required this.data, required this.data2, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.4,
      child: SfCartesianChart(
        isTransposed: true,
        primaryXAxis: CategoryAxis(),
        // primaryYAxis: NumericAxis(
        //   minimum:
        //       -200, // Adjust the minimum and maximum based on your data range.
        //   maximum: 200,
        //   interval: 50,
        // ),
        plotAreaBorderWidth: 0,
        series: <ChartSeries>[
          BarSeries<BarChartData, String>(
            dataSource: data,
            xValueMapper: (BarChartData value, _) => value.category,
            yValueMapper: (BarChartData value, _) => value.value,
            enableTooltip: true,
            animationDuration: 1000,
            color: const Color(0xff9AA0C5),
            //   dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
          BarSeries<BarChartData, String>(
            dataSource: data2,
            xValueMapper: (BarChartData value, _) => value.category,
            yValueMapper: (BarChartData value, _) => value.value,
            enableTooltip: true,
            animationDuration: 1000,
            color: color ?? Colors.red,
            //  dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}
