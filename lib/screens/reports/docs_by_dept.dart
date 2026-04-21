import 'dart:math';
import 'package:archiving_flutter_project/dialogs/fromDate_toDate_dialog.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/dto/reports_criteria.dart';
import '../../service/controller/reports_controller.dart';
import '../../utils/func/responsive.dart';
import '../../widget/charts.dart';
import '../../widget/dashboard_components/DashboardActionButton.dart';
import '../../widget/dashboard_components/dashboard_header.dart';
import '../../widget/dashboard_components/pie_dashboard_chart.dart';
import '../../widget/pie_chart_model.dart';

class DocsByDeptDashboard extends StatefulWidget {
  const DocsByDeptDashboard({Key? key}) : super(key: key);

  @override
  State<DocsByDeptDashboard> createState() => _DocsByDeptDashboardState();
}

class _DocsByDeptDashboardState extends State<DocsByDeptDashboard> {
  bool isDesktop = false;
  late AppLocalizations _locale;
  ReportsController reportsController = ReportsController();
  List<PieChartModel> barDataDailySales = [];
  List<BarData> barData = [];

  ReportsCriteria? searchCriteria = ReportsCriteria(
    fromDate: Converters.getDateBeforeMonth(),
    toDate: Converters.formatDate2(DateTime.now().toString()),
  );

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    docByCat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);

    return Column(
      children: [
        DashboardHeader(
          title: _locale.docByDep,
          subtitle:
              '${searchCriteria?.fromDate ?? ''} - ${searchCriteria?.toDate ?? ''}',
          accentColor: const Color(0xFF185FA5),
          actions: [
            DashboardActionButton(
              icon: Icons.filter_list_sharp,
              color: const Color(0xFF185FA5),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => FromDateToDateDialog(
                    searchCriteria: searchCriteria,
                  ),
                ).then((value) {
                  if (value != null && value is ReportsCriteria) {
                    searchCriteria = value;
                    barData.clear();
                    barDataDailySales.clear();
                    docByCat();
                  }
                });
              },
            ),
          ],
        ),
        Expanded(
          child: barDataDailySales.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pie_chart_outline,
                          size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        _locale.nodataSelected,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: PieDashboardChart(
                        dataList: barDataDailySales,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        child: _buildLegend(),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final double total =
        barDataDailySales.fold(0.0, (sum, e) => sum + (e.value ?? 0));

    return ListView.builder(
      itemCount: barDataDailySales.length,
      itemBuilder: (context, index) {
        final item = barDataDailySales[index];
        final double val = item.value ?? 0;
        final double pct = total > 0 ? (val / total * 100) : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),

 
              Expanded(
                child: Text(
                  item.title ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D3D3A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.color?.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: item.color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> docByCat() async {
    barData = [];
    await reportsController.getDocByDept(searchCriteria!).then((response) {
      for (var element in response) {
        String temp = element.dept ?? "NO DATE";
        double countFiles = double.parse(element.countFiles.toString());
        barData.add(BarData(name: temp, percent: countFiles));
        barDataDailySales.add(PieChartModel(
          title: temp,
          value: countFiles,
          color: getRandomColor(),
        ));
      }
    });
    setState(() {});
  }

  Color getRandomColor() {
    const List<Color> palette = [
      Color(0xFF185FA5),
      Color(0xFF0D9B8A),
      Color(0xFF534AB7),
      Color(0xFFBA7517),
      Color(0xFFA32D2D),
      Color(0xFF3B6D11),
      Color(0xFF0F6E56),
      Color(0xFF993556),
      Color(0xFF5F5E5A),
      Color(0xFF185FA5),
    ];
    final random = Random();
    return palette[random.nextInt(palette.length)];
  }
}
