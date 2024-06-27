import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/service/controller/actions_controllers/action_controller.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../utils/constants/sorted_by_constant.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/date_time_component.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';

class AddEditActionDialog extends StatefulWidget {
  ActionModel? actionModel;
  bool? isFromList;
  String? title;
  AddEditActionDialog(
      {super.key, this.isFromList, this.actionModel, this.title});

  @override
  State<AddEditActionDialog> createState() => _AddEditActionDialogState();
}

class _AddEditActionDialogState extends State<AddEditActionDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;

  TextEditingController dateController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  ActionController actionController = ActionController();
  String isRecurring = "";

  int selectedStatus = -1;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    if (widget.isFromList!) {
      descController.text = widget.actionModel!.txtDescription!;
    } else if (widget.actionModel != null) {
      dateController.text = widget.actionModel!.datDate!;
      descController.text = widget.actionModel!.txtDescription!;
      notesController.text = widget.actionModel!.txtNotes!;
      isRecurring = widget.actionModel!.intRecurring == 1
          ? _locale.monthly
          : _locale.weekly;
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
        title: widget.title!,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: isDesktop ? height * 0.3 : height * 0.5,
        child: SingleChildScrollView(
          child: formSection(),
        ),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addAction();
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        14,
                        primary),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  SizedBox(width: width * 0.01),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        14,
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
                          addAction();
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isDesktop)
          DateTimeComponent(
            label: _locale.date,
            dateController: dateController,
            dateWidth: width * 0.2,
            dateControllerToCompareWith: null,
            readOnly: false,
            isInitiaDate: true,
            onValue: (isValid, value) {
              if (isValid) {
                dateController.text = value;
              }
            },
            timeControllerToCompareWith: null,
          ),
        customTextField(
          _locale.txtDescription,
          descController,
          isDesktop,
          0.2,
          true,
        ),
        customTextField(
          _locale.notes,
          notesController,
          isDesktop,
          0.2,
          true,
        ),
        // Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.center,
        // children: [
        //     Checkbox(
        //       activeColor: primary2,
        //       value: isRecurring,
        //       onChanged: (value) {
        //         setState(() {
        //           isRecurring = value!;
        //         });
        //       },
        //     ),
        //     Text(_locale.recurring),
        //   ],
        // ),
        DropDown(
          key: UniqueKey(),
          onChanged: (value) {
            selectedStatus = getRecurringCode(_locale, value);
          },
          initialValue: isRecurring == "" ? null : isRecurring,
          bordeText: _locale.recurring,
          items: getRecurringName(_locale),
          width: width * 0.2,
          height: height * 0.045,
        ),
        if (!isDesktop) ...[
          DateTimeComponent(
            label: _locale.date,
            dateController: dateController,
            dateWidth: width * 0.15,
            dateControllerToCompareWith: null,
            readOnly: false,
            isInitiaDate: true,
            onValue: (isValid, value) {
              if (isValid) {
                dateController.text = value;
              }
            },
            timeControllerToCompareWith: null,
          ),
          customTextField(
            _locale.txtDescription,
            descController,
            isDesktop,
            0.8,
            true,
          ),
          customTextField(
            _locale.notes,
            notesController,
            isDesktop,
            0.2,
            true,
          ),
          DropDown(
            key: UniqueKey(),
            onChanged: (value) {
              selectedStatus = getRecurringCode(_locale, value);
            },
            initialValue: selectedStatus == -1
                ? null
                : getRecurringByCode(_locale, selectedStatus),
            bordeText: _locale.recurring,
            items: getRecurringName(_locale),
            width: width * 0.2,
            height: height * 0.04,
          ),
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
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: height * 0.05,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }

  void addAction() async {
    if (descController.text.trim().isEmpty ||
        notesController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.error,
              errorDetails: _locale.error,
              errorTitle: _locale.pleaseAddAllRequiredFields,
              color: Colors.red,
              statusCode: 400);
        },
      );
    } else if (widget.actionModel != null && widget.isFromList == false) {
      editMethod();
    } else if (widget.isFromList == true) {
      ActionModel actionModel = ActionModel(
        txtKey: null,
        txtDescription: descController.text,
        txtNotes: notesController.text,
        datDate: dateController.text,
        intRecurring: isRecurring == false ? 0 : 1,
      );
      await actionController.addAction(actionModel).then((value) {
        if (value.statusCode == 200) {
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
      });
    } else {
      ActionModel actionModel = ActionModel(
        txtKey: null,
        txtDescription: descController.text,
        txtNotes: notesController.text,
        datDate: dateController.text,
        intRecurring: isRecurring == false ? 0 : 1,
      );
      await actionController.addAction(actionModel).then((value) {
        if (value.statusCode == 200) {
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
      });
    }
  }

  void editMethod() async {
    ActionModel actionModel = ActionModel(
        txtKey: widget.actionModel!.txtKey!,
        txtDescription: descController.text,
        datDate: dateController.text,
        intRecurring: isRecurring == false ? 0 : 1,
        txtNotes: notesController.text);
    await actionController.updateAction(actionModel).then((value) {
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
