import 'package:archiving_flutter_project/models/dto/reports_criteria.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../service/controller/reports_controller.dart';
import '../../service/controller/users_controller/user_controller.dart';
import '../../utils/func/converters.dart';
import '../../widget/charts.dart';
import '../../widget/custom_cards.dart';
import '../../widget/dashboard_components/bar_dashboard_chart.dart';
import '../../widget/dashboard_components/card_content.dart';
import 'docs_by_cat_dashboard.dart';
import 'docs_by_dept.dart';
import 'user_doc_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;

  Color currentColor = Color.fromARGB(255, 225, 65, 65);
  Color selectedColor = Colors.grey;
  bool isDesktop = false;
  List<BarData> barData = [];
  ValueNotifier totalUserCat = ValueNotifier(0);
  ValueNotifier totalDocumnetsCount = ValueNotifier(0);
  ValueNotifier totalDepartmentsCount = ValueNotifier(0);

  ReportsController reportsController = ReportsController();
  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    super.didChangeDependencies();
  }

  @override
  void initState() {
    getCounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.dashboard),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomCards(
                                  height: height * 0.144,
                                  content: ValueListenableBuilder(
                                    valueListenable: totalUserCat,
                                    builder: (context, value, child) {
                                      return CardContent(
                                        title: _locale.totalCat,
                                        value: value.toString(),
                                        icon: Icons
                                            .supervised_user_circle_outlined,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * 0.009,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomCards(
                                  height: height * 0.144,
                                  content: ValueListenableBuilder(
                                    valueListenable: totalDocumnetsCount,
                                    builder: (context, value, child) {
                                      return CardContent(
                                        title: _locale.totalDocs,
                                        value: value.toString(),
                                        icon: Icons.document_scanner,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * 0.009,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomCards(
                                  height: height * 0.144,
                                  content: ValueListenableBuilder(
                                    valueListenable: totalDepartmentsCount,
                                    builder: (context, value, child) {
                                      return CardContent(
                                        title: _locale.totalDepts,
                                        value: value.toString(),
                                        icon: Icons.category,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * 0.005,
                    ),
                    Expanded(
                      flex: 3,
                      child: CustomCards(
                        height: height * 0.45,
                        content: const UserDocDashboard(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.005,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomCards(
                        height: height * 0.45,
                        content: const DocsByCatDashboard(),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.005,
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomCards(
                        height: height * 0.45,
                        content: const DocsByDeptDashboard(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  getCounts() {
    UserController().getUserCatCount().then((value) {
      totalUserCat.value = value;
    });
    DocumentsController().getDocCatCount().then((value) {
      totalDocumnetsCount.value = value;
    });
    DepartmentController().getOfficeCount().then((value) {
      totalDepartmentsCount.value = value;
    });
  }
}
