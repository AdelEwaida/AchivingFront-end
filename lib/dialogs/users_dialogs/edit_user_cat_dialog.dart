import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/db/user_models/user_category.dart';
import '../../models/db/user_models/user_update_req.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../../widget/text_field_widgets/test_drop_down.dart';

class EditUserCategoryDialog extends StatefulWidget {
  UserCategory? userCategoryModel;
  EditUserCategoryDialog({super.key, this.userCategoryModel});

  @override
  State<EditUserCategoryDialog> createState() => _EditUserCategoryDialogState();
}

class _EditUserCategoryDialogState extends State<EditUserCategoryDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;
  TextEditingController userListController = TextEditingController();
  UserController userController = UserController();

  String hintUsers = "";
  List<String>? usersList;
  List<UserCategory> usersListCode = [];
  List<UserCategory>? usersListModel = [];

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    if (widget.userCategoryModel != null) {
      hintUsers = widget.userCategoryModel!.userName!;
    }
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
        title: _locale.updateUserCat,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: isDesktop ? height * 0.2 : height * 0.5,
        child: SingleChildScrollView(
          child: formSection(),
        ),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addDep();
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
                          addDep();
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
    return Column(
      children: [
        if (isDesktop)
          Tooltip(
            message: hintUsers,
            child: TestDropdown(
              cleanPrevSelectedItem: true,
              icon: const Icon(Icons.search),
              isEnabled: true,
              stringValue:
                  usersListModel!.map((e) => e.userName!).join(', ').isEmpty
                      ? null
                      : usersListModel!.map((e) => e.userName!).join(', '),
              borderText: _locale.users,
              onClearIconPressed: () {
                setState(() {
                  usersListCode.clear();
                  hintUsers = "";
                  usersListCode = [];
                });
              },
              onChanged: (val) {
                usersListCode.clear();
                for (int i = 0; i < val.length; i++) {
                  usersListCode.add(val[i]);
                }
                usersListModel!.addAll(usersListCode);
                if (usersListModel!.isEmpty) {
                  hintUsers = "";
                } else {
                  hintUsers = "";

                  hintUsers = usersListModel!.map((e) => e.userId!).join(', ');
                  // Removing the last comma and space if exists
                  if (hintUsers.endsWith(', ')) {
                    hintUsers = hintUsers.substring(0, hintUsers.length - 2);
                  }
                }

                setState(() {});
              },
              onSearch: (text) async {
                List<UserCategory> newList = await userController
                    .getUsersByCatMethod(widget.userCategoryModel!.categoryId!);
                return newList;
              },
            ),
          ),
        if (!isDesktop) ...[
          customTextField(
              _locale.txtShortcode, userListController, isDesktop, 0.8, true),
        ],
      ],
    );
  }

  Widget row(Widget widget1, Widget widget2) {
    return Row(
      children: [
        widget1,
        SizedBox(
          width: width * 0.003,
        ),
        widget2
      ],
    );
  }

  Widget customTextField(String hint, TextEditingController controller,
      bool isDesktop, double width1, bool isMandetory) {
    return CustomTextField2(
      readOnly: false,
      // inputFormatters: hint == _locale.phoneNumber
      //     ? [
      //         FilteringTextInputFormatter.digitsOnly,
      //         LengthLimitingTextInputFormatter(14),
      //         PhoneNumberFormatter(),
      //       ]
      //     : null,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: hint == _locale.notes ? height * 0.1 : height * 0.05,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }

  void addDep() async {
    if (widget.userCategoryModel != null) {
      editMethod();
    }
  }

  void editMethod() async {
    if (widget.userCategoryModel != null) {
      UserUpdateReq userUpdateReq = UserUpdateReq(
        userCategory: widget.userCategoryModel!.categoryId,
        users: usersListCode,
      );

      await userController.updateUserCatgeory(userUpdateReq).then((value) {
        if (value.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                  icon: Icons.done_all,
                  errorDetails: _locale.done,
                  errorTitle: _locale.editDoneSucess,
                  color: Colors.green,
                  statusCode: 200);
            },
          ).then((value) {
            Navigator.pop(context, true);
          });
        }
      });
    }
  }
}
