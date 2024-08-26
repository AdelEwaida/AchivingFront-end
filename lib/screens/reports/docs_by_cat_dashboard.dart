import 'dart:convert';
import 'dart:math';
import 'package:archiving_flutter_project/dialogs/fromDate_toDate_dialog.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/func/dates_controller.dart';
import '../../models/dto/reports_criteria.dart';
import '../../service/controller/reports_controller.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/responsive.dart';
import '../../widget/charts.dart';
import '../../widget/dashboard_components/bar_dashboard_chart.dart';

class DocsByCatDashboard extends StatefulWidget {
  const DocsByCatDashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<DocsByCatDashboard> createState() => _DocsByCatDashboardState();
}

class _DocsByCatDashboardState extends State<DocsByCatDashboard> {
  double width = 0;
  double height = 0;
  final dropdownKey = GlobalKey<DropdownButton2State>();
  bool isDesktop = false;
  final storage = const FlutterSecureStorage();
  late AppLocalizations _locale;
  ReportsController reportsController = ReportsController();

  List<String> status = [];

  List<String> charts = [];

  bool accountsActive = false;

  TextEditingController fromDateController = TextEditingController();
  int statusVar = 0;

  String todayDate = "";

  int selectedStatus = 0;
  int selectedChart = 0;
  List<double> listOfBalances = [];
  List<String> listOfPeriods = [];
  final dataMap = <String, double>{};
  bool boolTemp = false;
  List<BarData> barData = [];

  String lastBranchCode = "";

  // List<PieChartModel> pieData = [];
  String accountNameString = "";
  String lastFromDate = "";
  String lastStatus = "";

  String startSearchCriteria = "";
  String currentPageName = "";
  String currentPageCode = "";

  String txtKey = "";
  int counter = 0;
  bool isLoading = true;
  List<String> branches = [];
  ReportsCriteria? searchCriteria = ReportsCriteria(
      fromDate: Converters.getDateBeforeMonth(),
      toDate: Converters.formatDate2(DateTime.now().toString()));
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    docByCat();

    super.didChangeDependencies();
  }

  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    isDesktop = Responsive.isDesktop(context);

    // Only render the chart if the data has been loaded
    if (barData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 5, right: 5, bottom: 3, top: 0),
            child: Container(
              height: isDesktop ? height * 0.44 : height * 0.48,
              padding: const EdgeInsets.only(left: 5, right: 5, top: 0),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _locale.docByCat,
                        style: TextStyle(fontSize: isDesktop ? 15 : 18),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width < 800
                              ? MediaQuery.of(context).size.width * 0.06
                              : MediaQuery.of(context).size.width * 0.03,
                          child: blueButton1(
                            icon: Icon(
                              Icons.filter_list_sharp,
                              color: whiteColor,
                              size: isDesktop ? height * 0.035 : height * 0.03,
                            ),
                            textColor: const Color.fromARGB(255, 255, 255, 255),
                            height: isDesktop ? height * .01 : height * .039,
                            fontSize: isDesktop ? height * .018 : height * .017,
                            width: isDesktop ? width * 0.08 : width * 0.27,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return FromDateToDateDialog(
                                    searchCriteria: searchCriteria,
                                  );
                                },
                              ).then((value) {
                                if (value != null) {
                                  searchCriteria = value;
                                  barData.clear();
                                  docByCat();
                                }
                              });
                            },
                          )),
                    ],
                  ),
            
                  BarDashboardChart(
                    key: UniqueKey(),
                    barChartData: barData,
                    isMax: true,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> docByCat() async {
    // ReportsCriteria searchCriteria =
    //     ReportsCriteria(fromDate: "2024-07-02", toDate: "2024-08-22");

    // barData = [];

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