import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/dates_provider.dart';
import '../service/controller/error_controllers/error_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/func/responsive.dart';

// ignore: must_be_immutable
class DateTimeComponent extends StatefulWidget {
  final String? label;
  int? minYear;
  double? height;
  Function(bool isValid, String value)? onValue;
  bool? ddmmyyyy;
  final TextEditingController? dateController;
  String? date;
  bool? readOnly;
  TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final Function(String newDate, String oldDate)? onDateChanged;
  double? dateWidth;
  bool? isTimeDate;
  final TextEditingController? dateControllerToCompareWith;
  final TimeOfDay? timeControllerToCompareWith;

  bool isInitiaDate;
  DateTimeComponent(
      {super.key,
      this.label,
      this.onValue,
      this.dateWidth,
      this.height,
      required this.dateControllerToCompareWith,
      required this.isInitiaDate,
      required this.timeControllerToCompareWith,
      this.isTimeDate,
      this.onDateChanged,
      this.selectedTime,
      this.onTimeChanged,
      this.dateController,
      this.minYear,
      this.ddmmyyyy,
      this.date,
      this.readOnly});

  @override
  State<DateTimeComponent> createState() => _DateTimeComponentState();
}

class _DateTimeComponentState extends State<DateTimeComponent> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  final MaskTextInputFormatter _maskYear =
      MaskTextInputFormatter(mask: "####", type: MaskAutoCompletionType.eager);
  final MaskTextInputFormatter _maskDayMonth =
      MaskTextInputFormatter(mask: "##", type: MaskAutoCompletionType.eager);

  TextEditingController yearController = TextEditingController();
  TextEditingController monthController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  DateTime formattedDate = DateTime.now();

  String yearHint = "YYYY";
  String monthHint = "MM";
  String dayHint = "DD";

  Color borderColor = Colors.grey;
  Color borderErrorColor = Colors.red;
  double borderRadius = 5;
  // TimeOfDay? selectedTime;
  bool isValid = false;

  String activeDateErrorMessage = "Check Your Input Format!";
  String yearIsGreater = "Year is Wrong";
  String monthIsGreater = "Month is Wrong";
  String dayIsGreater = "Day is Wrong";
  TextEditingController controller = TextEditingController();

  FocusNode yearFocusNode = FocusNode();
  FocusNode monthFocusNode = FocusNode();
  FocusNode dayFocusNode = FocusNode();

  bool dayTemp = true;
  bool monthTemp = true;
  bool yearTemp = true;
  @override
  void initState() {
    setListeners();
    clearDateProvider();
    super.initState();
  }

  clearDateProvider() {
    if (!context.read<DatesProvider>().dayTemp) {
      dayTemp = true;
      context.read<DatesProvider>().setDayTemp(true);
    } else if (!context.read<DatesProvider>().monthTemp) {
      monthTemp = true;
      context.read<DatesProvider>().setMonthTemp(true);
    } else if (!context.read<DatesProvider>().yearTemp) {
      yearTemp = true;
      context.read<DatesProvider>().setYearTemp(true);
    }
    setState(() {});
  }

  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  splitDate() {
    controller = widget.dateController!;
    return controller.text.split("-");
  }

  @override
  void dispose() {
    yearFocusNode.dispose();
    monthFocusNode.dispose();
    dayFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    selectedTime = widget.selectedTime;
    selectedDate = DateFormat('yyyy-MM-dd').parse(widget.dateController!.text);

    String label = widget.label ?? "";

    if (widget.dateController!.text.isNotEmpty) {
      formattedDate =
          DateFormat('yyyy-MM-dd').parse(widget.dateController!.text);

      yearController.text = splitDate()[0];
      monthController.text = splitDate()[1];
      dayController.text = splitDate()[2];
    }

    return SizedBox(
      width: widget.isTimeDate == true
          ? width * 0.19
          : widget.dateWidth ?? width * 0.13,
      // height: height * 0.09,

      child: Column(
        children: [
          Consumer<DatesProvider>(
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  labelMessage(label),
                  !dayTemp || !monthTemp || !yearTemp
                      ? errorMessage(_locale.validDate)
                      : const SizedBox.shrink(),
                ],
              );
            },
          ),
          Container(
            //  width: width * 0.9,
            height: widget.height ?? height * 0.04,
            decoration: BoxDecoration(
              // color: Colors.white,

              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getSuffixIcon(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    createDateField(
                        _maskDayMonth, dayController, dayHint, dayFocusNode),
                    dateDivider(),
                    createDateField(_maskDayMonth, monthController, monthHint,
                        monthFocusNode),
                    dateDivider(),
                    createDateField(
                        _maskYear, yearController, yearHint, yearFocusNode),
                  ],
                ),
                widget.isTimeDate == true
                    ? const VerticalDivider(
                        color: Color.fromARGB(255, 97, 97, 97),
                        thickness: 0.5,
                        width: 15,
                      )
                    : Container(),
                widget.isTimeDate == true
                    ? Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              if (widget.readOnly == true) {
                              } else {
                                await showTimePicker(
                                  context: context,
                                  initialTime:
                                      widget.selectedTime ?? TimeOfDay.now(),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: Colors.blue,
                                        colorScheme: const ColorScheme.light(
                                            primary: Colors.blue),
                                        buttonTheme: const ButtonThemeData(
                                          textTheme: ButtonTextTheme.normal,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                ).then((value) {
                                  widget.selectedTime = value;

                                  if (widget.dateControllerToCompareWith !=
                                      null) {
                                    DateTime dateController = DateTime.parse(
                                        widget.dateController!.text);
                                    DateTime dateController2 = DateTime.parse(
                                        widget
                                            .dateControllerToCompareWith!.text);
                                    if (dateController
                                        .isAtSameMomentAs(dateController2)) {
                                      checkTimeValidation();
                                    }
                                  }

                                  if (value != null) {
                                    widget.onTimeChanged!(widget.selectedTime);
                                  }
                                });
                              }
                            },
                            child: Icon(
                              Icons.timer,
                              color: primary2,
                              size: MediaQuery.of(context).size.width * 0.012,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (widget.readOnly == true) {
                              } else {
                                await showTimePicker(
                                  context: context,
                                  initialTime:
                                      widget.selectedTime ?? TimeOfDay.now(),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: Colors.blue,
                                        colorScheme: const ColorScheme.light(
                                            primary: Colors.blue),
                                        buttonTheme: const ButtonThemeData(
                                          textTheme: ButtonTextTheme.normal,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                ).then((value) {
                                  widget.selectedTime = value;

                                  if (widget.dateControllerToCompareWith !=
                                      null) {
                                    DateTime dateController = DateTime.parse(
                                        widget.dateController!.text);
                                    DateTime dateController2 = DateTime.parse(
                                        widget
                                            .dateControllerToCompareWith!.text);
                                    if (dateController
                                        .isAtSameMomentAs(dateController2)) {
                                      checkTimeValidation();
                                    }
                                  }

                                  if (value != null) {
                                    widget.onTimeChanged!(widget.selectedTime);
                                  }
                                });
                              }
                            },
                            child: Center(
                              child: Text(
                                widget.selectedTime != null
                                    ? widget.selectedTime!.format(context)
                                    : TimeOfDay.now().format(context),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: height * 0.0165),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox dateDivider() {
    return SizedBox(width: width * 0.003, child: const Text("-"));
  }

  Widget createDateField(MaskTextInputFormatter mask,
      TextEditingController controller, String hint, FocusNode focusNode) {
    return Center(
      child: SizedBox(
        width: Responsive.isDesktop(context) ? width * 0.026 : width * 0.07,
        height: Responsive.isDesktop(context) ? height * 0.03 : height * 0.1,
        child: Center(
          child: TextFormField(
            readOnly: widget.readOnly != null ? widget.readOnly! : false,
            style: TextStyle(fontSize: height * 0.0165),
            focusNode: focusNode,
            controller: controller,
            inputFormatters: [mask],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
            onTap: () {
              if (hint == dayHint) {
                if (dayController.text.isNotEmpty) {
                  dayController.selection = TextSelection(
                      baseOffset: 0, extentOffset: dayController.text.length);
                }
              } else if (hint == monthHint) {
                if (monthController.text.isNotEmpty) {
                  monthController.selection = TextSelection(
                      baseOffset: 0, extentOffset: monthController.text.length);
                }
              } else if (hint == yearHint) {
                if (yearController.text.isNotEmpty) {
                  yearController.selection = TextSelection(
                      baseOffset: 0, extentOffset: yearController.text.length);
                }
              }
            },
            onChanged: (value) {
              setRequestNodes(hint);
              print("ooooooooooo $value");

              if (dayController.text.length == 2 &&
                  monthController.text.length == 2 &&
                  yearController.text.length == 4) {
                print("ooooooooooo 22 $value");
                widget.dateController!.text =
                    '${yearController.text}-${monthController.text}-${dayController.text}';
                submitValueDate(focusNode);

                formattedDate =
                    DateFormat('yyyy-MM-dd').parse(widget.dateController!.text);
              }

              if (widget.dateControllerToCompareWith != null) {
                checkValidation();
              }
            },
            onFieldSubmitted: (value) {
              submitValueDate(focusNode);
              if (widget.dateControllerToCompareWith != null) {
                checkValidation();
              }
            },
          ),
        ),
      ),
    );
  }

  void checkValidation() {
    TimeOfDay timeController =
        widget.selectedTime ?? const TimeOfDay(hour: 00, minute: 00);
    TimeOfDay timeController2 = widget.timeControllerToCompareWith ??
        const TimeOfDay(hour: 00, minute: 00);
    DateTime dateController = DateTime.parse(widget.dateController!.text);
    DateTime dateController2 =
        DateTime.parse(widget.dateControllerToCompareWith!.text);
    if (widget.isInitiaDate == false) {
      if (dateController.isBefore(dateController2)) {
        ErrorController.openErrorDialog(1, _locale.startDateAfterEndDate);

        widget.dateController!.text =
            DateFormat('yyyy-MM-dd').format(selectedDate!);

        setState(() {});
      } else if (dateController.isAtSameMomentAs(dateController2) &&
          (timeController.hour < timeController2.hour ||
              (timeController.hour == timeController2.hour &&
                  timeController.minute < timeController2.minute))) {
        ErrorController.openErrorDialog(2, _locale.startTimeAfterEndTime);

        widget.dateController!.text =
            DateFormat('yyyy-MM-dd').format(selectedDate!);

        setState(() {});
      } else {
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(widget.dateController!.text,
              DateFormat('yyyy-MM-dd').format(selectedDate!));
        }
      }
    } else if (widget.isInitiaDate == true) {
      if (dateController.isAfter(dateController2)) {
        ErrorController.openErrorDialog(1, _locale.startDateAfterEndDate);

        widget.dateController!.text =
            DateFormat('yyyy-MM-dd').format(selectedDate!);

        setState(() {});
      } else if (dateController.isAtSameMomentAs(dateController2) &&
          (timeController.hour > timeController2.hour ||
              (timeController.hour == timeController2.hour &&
                  timeController.minute > timeController2.minute))) {
        ErrorController.openErrorDialog(2, _locale.startTimeAfterEndTime);

        widget.dateController!.text =
            DateFormat('yyyy-MM-dd').format(selectedDate!);

        setState(() {});
      } else {
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(widget.dateControllerToCompareWith!.text,
              DateFormat('yyyy-MM-dd').format(selectedDate!));
        }
      }
    }
  }

  void checkTimeValidation() {
    TimeOfDay timeController = widget.selectedTime!;
    TimeOfDay timeController2 = widget.timeControllerToCompareWith!;
    if (widget.isInitiaDate == false) {
      if (timeController.hour < timeController2.hour ||
          (timeController.hour == timeController2.hour &&
              timeController.minute < timeController2.minute)) {
        ErrorController.openErrorDialog(2, _locale.startTimeAfterEndTime);
        widget.selectedTime = selectedTime;

        setState(() {});
      }
    } else if (widget.isInitiaDate == true) {
      if (timeController.hour > timeController2.hour ||
          (timeController.hour == timeController2.hour &&
              timeController.minute > timeController2.minute)) {
        ErrorController.openErrorDialog(2, _locale.startTimeAfterEndTime);
        widget.selectedTime = selectedTime;

        setState(() {});
      }
    }
  }

  emptyDateControllers() {
    if (yearController.text.isNotEmpty &&
        monthController.text.isNotEmpty &&
        dayController.text.isNotEmpty) {
      yearController.clear();
      dayController.clear();
      monthController.clear();
    }
    if (yearController.text.isNotEmpty) {
      yearController.clear();
    } else if (dayController.text.isNotEmpty) {
      dayController.clear();
    } else if (monthController.text.isNotEmpty) {
      monthController.clear();
    }
  }

  void submitValueDate(FocusNode focusNode) {
    checkDates();
    if (!isValid) {
      focusNode.requestFocus();
    } else {
      if (widget.onValue != null) {
        // String dateValue = getDateValue();

        widget.onValue!(isValid, getDateValue());
      }
    }
  }

  Widget getSuffixIcon() {
    return InkWell(
      onTap: () {
        if (widget.readOnly == true) {
        } else {
          setDatePickerValues();
        }
      },
      child: Icon(
        Icons.date_range,
        size: MediaQuery.of(context).size.width * 0.012,
        color: primary2,
      ),
    );
  }

  bool dateValidation() {
    String yearStr = yearController.text;
    String monthStr = monthController.text;
    String dayStr = dayController.text;

    DateTime dateTime = DateTime.now();

    int yearNow = dateTime.year;

    if (yearStr.isNotEmpty && yearStr.length == 4) {
      int minYear = widget.minYear ?? 2000;
      int year = int.parse(yearStr);
      if (year < minYear) {
        yearController.text = yearNow.toString();
        return true;
      }
    }

    if (monthStr.isNotEmpty && monthStr.length == 2) {}

    if (yearStr.length != 4 || monthStr.length != 2 || dayStr.length != 2) {
      return false;
    }

    try {
      int month = int.parse(monthStr);
      int day = int.parse(dayStr);

      if (yearStr.length == 4) {
        if (month <= 12) {
          if (dayStr.length == 2) {
            if ((month == 4 || month == 6 || month == 9 || month == 11) &&
                day <= 30) {
              return true;
            } else if ((month == 4 ||
                    month == 6 ||
                    month == 9 ||
                    month == 11) &&
                day > 30) {
              dayController.text = 30.toString();
              return true;
            } else if (month == 2 && day <= 29) {
              return true;
            } else if (month == 2 && day > 29) {
              dayController.text = 29.toString();

              return true;
            } else if (day <= 31) {
              return true;
            } else if (day > 31) {
              dayController.text = 31.toString();
              return true;
            }
          }

          //If no condition above true for the day
          // activeDateErrorMessage = dayIsGreater;
        } else {
          // activeDateErrorMessage = monthIsGreater;
          // monthController.text = monthNow.toString();
        }
      } else {
        // yearController.text = yearNow.toString();
        // activeDateErrorMessage = yearIsGreater;
      }
    } catch (e) {
      // String yearStr = yearController.text;
      // String monthStr = monthController.text;
      // String dayStr = dayController.text;

      // print("There was an error with date validation");
    }
    return false;
  }

  Widget errorMessage(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        msg,
        style: TextStyle(
          fontSize: 10,
          color: borderErrorColor,
        ),
      ),
    );
  }

  Widget labelMessage(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        style: const TextStyle(fontSize: 12),
        msg,
      ),
    );
  }

  void setRequestNodes(String hint) {
    String year = yearController.text;
    String month = monthController.text;
    String day = dayController.text;
    DateTime dateTime = DateTime.now();

    if (hint.compareTo(dayHint) == 0) {
      if (day.length == 2) {
        dayController.text = dayController.text;
        if (int.parse(dayController.text) > 31 &&
            dayController.text[0] != "0") {
          dayTemp = false;
          context.read<DatesProvider>().setDayTemp(false);
          setState(() {});

          dayController.text = dateTime.day.toString();
        } else {
          // dayController.text = dateTime.day.toString();
          context.read<DatesProvider>().setDayTemp(true);

          dayTemp = true;
          setState(() {});
        }
        if (dayTemp) {
          monthFocusNode.requestFocus();
        }
      }
    } else if (hint.compareTo(monthHint) == 0 && day.isNotEmpty) {
      if (month.length == 2) {
        monthController.text = monthController.text;
        if (int.parse(monthController.text) > 12 &&
            monthController.text[0] != "0") {
          monthTemp = false;
          context.read<DatesProvider>().setMonthTemp(false);
          setState(() {});

          monthController.text = dateTime.month.toString();
        } else {
          // dayController.text = dateTime.day.toString();
          context.read<DatesProvider>().setMonthTemp(true);

          monthTemp = true;
          setState(() {});
        }
        if (monthTemp) {
          yearFocusNode.requestFocus();
        }
      }
    } else {
      if (year.length == 4) {
        yearController.text = yearController.text;
        // if (yearController.text[0] != "0") {
        //   // yearController.text = dateTime.year.toString();
        //   // yearTemp = false;
        //   context.read<DatesProvider>().setYearTemp(false);

        //   // setState(() {});

        //   yearController.text = dateTime.year.toString();
        // } else {
        // yearController.text = dateTime.year.toString();
        // yearTemp = true;
        context.read<DatesProvider>().setYearTemp(true);
        yearTemp = true;
        setState(() {});
        // }
        // yearFocusNode.unfocus();

        isValid = dateValidation();

        if (isValid && textNotEmpty()) {
          if (widget.onValue != null) {
            String dateValue = getDateValue();
            widget.onValue!(isValid, dateValue);
          }
        }
      }
    }
    //Goes to month after finishing year
    // if (hint.compareTo(yearHint) == 0 && year.length == 4) {
    //   monthFocusNode.requestFocus();
    // } else if (hint.compareTo(monthHint) == 0 && year.isNotEmpty) {
    //   if (month.length == 2) {
    //     dayFocusNode.requestFocus();
    //   }
    // } else if (hint.compareTo(dayHint) == 0 &&
    //     year.isNotEmpty &&
    //     month.isNotEmpty) {
    //   if (day.length == 2) {
    //     dayFocusNode.unfocus();
    //   }
    // }
  }

  void setListeners() {
    yearFocusNode.addListener(() {
      // String year = yearController.text;
      if (!yearFocusNode.hasFocus) {
        // setState(() {
        isValid = dateValidation();
        // if (widget.onValue != null) {
        //   String dateValue = getDateValue();
        //   widget.onValue!(isValid, dateValue);
        // }
        // });
      }

      bool backspaceKeyPressed = false;
      yearFocusNode.onKeyEvent = (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (!backspaceKeyPressed) {
            // Handle the backspace key press here
            yearController.text = "";
            backspaceKeyPressed = true;
          }
          return KeyEventResult.handled;
        } else {
          backspaceKeyPressed = false;
        }
        return KeyEventResult.ignored;
      };
    });

    monthFocusNode.addListener(() {
      String month = monthController.text;
      if (!monthFocusNode.hasFocus) {
        // print(month.length);
        if (month.length == 1) {
          if (month.compareTo("0") == 0) {
            monthController.text = "01";
          } else {
            monthController.text = "0$month";
          }
        } else if (month.compareTo("00") == 0) {
          monthController.text = "01";
        }
        // setState(() {
        isValid = dateValidation();
        // print("object9999999");
        // if (isValid) {
        //   if (widget.onValue != null) {
        //     String dateValue = getDateValue();
        //     widget.onValue!(isValid, dateValue);
        //   }
        // }
        // });
      }
      bool backspaceKeyPressed = false;
      monthFocusNode.onKeyEvent = (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (!backspaceKeyPressed) {
            // Handle the backspace key press here
            monthController.text = "";
            backspaceKeyPressed = true;
          }
          return KeyEventResult.handled;
        } else {
          backspaceKeyPressed = false;
        }
        return KeyEventResult.ignored;
      };
    });

    dayFocusNode.addListener(() {
      String day = dayController.text;
      if (!dayFocusNode.hasFocus) {
        if (day.length == 1) {
          if (day.compareTo("0") == 0) {
            dayController.text = "01";
          } else {
            dayController.text = "0$day";
          }
        } else if (day.compareTo("00") == 0) {
          dayController.text = "01";
        }
        // setState(() {
        isValid = dateValidation();
        // print("object9999999");
        // if (isValid) {
        //   if (widget.onValue != null) {
        //     String dateValue = getDateValue();
        //     widget.onValue!(isValid, dateValue);
        //   }
        // }
        // });
      }
      bool backspaceKeyPressed = false;
      dayFocusNode.onKeyEvent = (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (!backspaceKeyPressed) {
            // Handle the backspace key press here
            dayController.text = "";
            backspaceKeyPressed = true;
          }
          return KeyEventResult.handled;
        } else {
          backspaceKeyPressed = false;
        }
        return KeyEventResult.ignored;
      };
    });
  }

  String getDateValue() {
    String year = yearController.text;
    String month = monthController.text;
    String day = dayController.text;
    String yyyymmddd = "";
    String mmddyyyy = "";
    if (day.length == 1) {
      yyyymmddd = "$year-$month-0$day";
      mmddyyyy = "0$day-$month-$year";
    } else if (month.length == 1) {
      yyyymmddd = "$year-0$month-$day";
      mmddyyyy = "$day-0$month-$year";
    }
    if (day.length == 2 && month.length == 2) {
      yyyymmddd = "$year-$month-$day";
    }

    if (widget.ddmmyyyy != null) {
      if (widget.ddmmyyyy!) {
        return mmddyyyy;
      }
    }
    return yyyymmddd;
  }

  void setDatePickerValues() {
    DateTime firstDate = DateTime(2000);
    showDatePicker(
      context: context,
      initialDate: formattedDate,
      firstDate: firstDate,
      lastDate: DateTime(2050),
    ).then((dateResult) {
      setState(() {
        if (dateResult != null && widget.onValue != null) {
          yearController.text = dateResult.year.toString();
          monthController.text = dateResult.month.toString();
          dayController.text = dateResult.day.toString();
          if (monthController.text.length == 1) {
            monthController.text = "0${monthController.text}";
          }
          if (dayController.text.length == 1) {
            dayController.text = "0${dayController.text}";
          }
          bool isValid = dateValidation();

          if (isValid) {
            dayTemp = true;
            monthTemp = true;
            yearTemp = true;
            context.read<DatesProvider>().setDayTemp(true);
            context.read<DatesProvider>().setMonthTemp(true);
            context.read<DatesProvider>().setYearTemp(true);

            widget.onValue!(true, getDateValue());
            if (widget.dateControllerToCompareWith != null) {
              checkValidation();
            }
          }
        }
      });
    });
  }

  void checkDates() {
    String month = monthController.text;
    if (month.length == 1) {
      monthController.text = "0$month";
    }
    String day = dayController.text;
    if (day.length == 1) {
      dayController.text = "0$day";
    }

    isValid = dateValidation();
  }

  bool textNotEmpty() {
    if (yearController.text.isNotEmpty &&
        monthController.text.isNotEmpty &&
        dayController.text.isNotEmpty) {
      return true;
    }
    return false;
  }
}
