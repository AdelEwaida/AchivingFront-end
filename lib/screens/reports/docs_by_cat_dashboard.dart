import 'package:archiving_flutter_project/dialogs/fromDate_toDate_dialog.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/dto/reports_criteria.dart';
import '../../service/controller/reports_controller.dart';
import '../../utils/func/responsive.dart';
import '../../widget/charts.dart';
import '../../widget/dashboard_components/DashboardActionButton.dart';
import '../../widget/dashboard_components/bar_dashboard_chart.dart';
import '../../widget/dashboard_components/dashboard_header.dart';

class DocsByCatDashboard extends StatefulWidget {
  const DocsByCatDashboard({Key? key}) : super(key: key);

  @override
  State<DocsByCatDashboard> createState() => _DocsByCatDashboardState();
}

class _DocsByCatDashboardState extends State<DocsByCatDashboard> {
  bool isDesktop = false;
  final storage = const FlutterSecureStorage();
  late AppLocalizations _locale;
  ReportsController reportsController = ReportsController();
  List<BarData> barData = [];

  ReportsCriteria? searchCriteria = ReportsCriteria(
    fromDate: Converters.getSameDayLastYear(),
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
          title: _locale.docByCat,
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
                    docByCat();
                  }
                });
              },
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: BarDashboardChart(
              barChartData: barData,
              isMax: true,
              accentColor: const Color(0xFF534AB7),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> docByCat() async {
    barData.clear();
    await reportsController.getDocByCat(searchCriteria!).then((response) {
      for (var element in response) {
        String temp = element.cat ?? "NO DATE";
        double countFiles = double.parse(element.countFiles.toString());
        barData.add(BarData(name: temp, percent: countFiles));
      }
    });
    setState(() {});
  }
}
