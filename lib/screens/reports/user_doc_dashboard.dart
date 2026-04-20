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
import '../../widget/dashboard_components/DashboardActionButton.dart';
import '../../widget/dashboard_components/bar_dashboard_chart.dart';
import '../../widget/dashboard_components/dashboard_header.dart';
import '../../widget/dashboard_components/line_dasboard_chart.dart';
import '../../widget/dashboard_components/pie_dashboard_chart.dart';
import '../../widget/pie_chart_model.dart';

class UserDocDashboard extends StatefulWidget {
  const UserDocDashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<UserDocDashboard> createState() => _UserDocDashboardState();
}

class _UserDocDashboardState extends State<UserDocDashboard> {
  double width = 0;
  double height = 0;
  final dropdownKey = GlobalKey<DropdownButton2State>();
  bool isDesktop = false;
  final storage = const FlutterSecureStorage();
  late AppLocalizations _locale;
  ReportsController reportsController = ReportsController();

  List<String> status = [];

  List<String> charts = [];
  List<PieChartModel> userDocList = [];

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
    getUserDocs();

    _locale = AppLocalizations.of(context)!;
    // getUserDocs();

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

    // // Only render the chart if the data has been loaded
    // if (userDocList.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: isDesktop ? height * 0.44 : height * 0.48,
            padding: const EdgeInsets.only(left: 5, right: 5, top: 0),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardHeader(
                  title: _locale.userDocs,
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
                          barrierDismissible: false,
                          builder: (context) => FromDateToDateDialog(
                            searchCriteria: searchCriteria,
                          ),
                        ).then((value) {
                          if (value != null && value is ReportsCriteria) {
                            searchCriteria = value;
                            listOfBalances.clear();
                            listOfPeriods.clear();
                            userDocList.clear();
                            getUserDocs();
                          }
                        });
                      },
                    ),
                    DashboardActionButton(
                      icon: Icons.table_chart_outlined, // excel-like icon
                      color: const Color(
                          0xFF1A7A4A), // green like the excel button
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return FromDateToDateDialog(
                                searchCriteria: searchCriteria);
                          },
                        ).then((value) {
                          if (value != null && value is ReportsCriteria) {
                            searchCriteria = value;
                            listOfBalances.clear();
                            listOfPeriods.clear();
                            userDocList.clear();
                            getUserDocs();
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: height * .33,
                  child: LineDashboardChart(
                      isMax: false,
                      balances: listOfBalances,
                      periods: listOfPeriods),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getUserDocs() async {
    listOfBalances.clear();
    listOfPeriods.clear();
    userDocList.clear();
    await reportsController.getUserDocuments(searchCriteria!).then((response) {
      if (response.isNotEmpty) {
        for (var element in response) {
          String temp = element.username ?? "NO DATE";
          double countFiles = double.parse(element.countFiles.toString());
          listOfBalances.add(countFiles);
          print("countFiles ${countFiles}");
          listOfPeriods.add(
            element.username!.isNotEmpty ? element.username! : _locale.userName,
          );
          userDocList.add(PieChartModel(
              title: temp,
              value: countFiles,
              color: getRandomColor(colorNewList)));
        }
        print("Pie chart data length: ${userDocList.length}");

        for (var data in userDocList) {
          print("Title: ${data.title}, Value: ${data.value}");
        }
      } else {}
    });
    setState(() {});
  }

  Color getRandomColor(List<Color> colorList) {
    final random = Random();
    int r = random.nextInt(256); // 0 to 255
    int g = random.nextInt(256); // 0 to 255
    int b = random.nextInt(256); // 0 to 255

    // Create Color object from RGB values
    return Color.fromRGBO(r, g, b, 1.0);
  }
}
