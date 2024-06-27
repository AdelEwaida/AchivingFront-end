import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/text_field_widgets/custom_text_field2_.dart';

class UserDepartmentDialog extends StatefulWidget {
  UserModel? userModel;
  UserDepartmentDialog({super.key, this.userModel});

  @override
  State<UserDepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<UserDepartmentDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;

  UserController userController = UserController();
  List<PlutoColumn> polCol = [];
  late PlutoGridStateManager stateManager;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    fillColumns();
    super.didChangeDependencies();
  }

  bool isDesktop = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      backgroundColor: dBackground,
      title: TitleDialogWidget(
        title: _locale.chooseListOfDepartment,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
            width: isDesktop ? width * 0.31 : width * 0.8,
            height: isDesktop ? height * 0.5 : height * 0.5,
            child: formSection(),
          ),
        ],
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveDep();
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
                        primary),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.01,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
                        redColor),
                    child: Text(
                      _locale.cancel,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          saveDep();
                        },
                        style: customButtonStyle(
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            18,
                            greenColor),
                        child: Text(
                          _locale.save,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: customButtonStyle(
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            18,
                            redColor),
                        child: Text(
                          _locale.cancel,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ],
              )
      ],
    );
  }

  Widget formSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TableComponent(
          plCols: polCol,
          polRows: [],
          tableWidth: isDesktop ? width * 0.31 : width * 0.8,
          tableHeigt: isDesktop ? height * 0.4 : height * 0.5,
          onLoaded: (event) {
            stateManager = event.stateManager;
            loadData();
          },
        ),
      ],
    );
  }

  loadData() async {
    stateManager.setShowLoading(true);

    List<DepartmentUserModel> response =
        await userController.getDepartmentUser(widget.userModel!.txtCode!);
    for (int i = 0; i < response.length; i++) {
      stateManager.appendRows([response[i].toPlutoRow(i + 1)]);
    }
    stateManager.setShowLoading(false);
  }

  void fillColumns() {
    polCol.addAll([
      //txtCode
      PlutoColumn(
        title: _locale.description,
        field: "txtDeptName",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.status,
        field: "bolSelected",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
        renderer: (rendererContext) {
          return Center(
            child: Checkbox(
              value: rendererContext.cell.value == 1 ? true : false,
              onChanged: (bool? value) {
                rendererContext.cell.value = value! ? 1 : 0;
                setState(() {});
              },
            ),
          );
        },
      ),
    ]);
  }

  void saveDep() async {
    List<DepartmentUserModel> list = [];
    for (int i = 0; i < stateManager.rows.length; i++) {
      PlutoRow row = stateManager.rows[i];
      if (row.cells['bolSelected']!.value == 1) {
        list.add(DepartmentUserModel.fromPlutoRow(row));
      }
    }
    var response = await userController.setUserDepartment(list);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.done_all,
              errorDetails: _locale.done,
              errorTitle: _locale.addDoneSucess,
              color: Colors.green,
              statusCode: 200);
        },
      ).then((value) {
        Navigator.pop(context, true);
      });
    }
  }
}
