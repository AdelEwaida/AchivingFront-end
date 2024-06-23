import 'package:intl/intl.dart';

class DatesController {
  Future<void> searchPerformanse(String selectedDate) async {
    print('Performing search for date: $selectedDate');
  }

  DateTime today = DateTime.now();
  String todayDate() {
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(today);
  }

  String currentWeek() {
    int daysUntilFirstDay = (today.weekday + 2) - DateTime.monday;
    DateTime firstDayCurrentWeek =
        today.subtract(Duration(days: daysUntilFirstDay));
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(firstDayCurrentWeek);
  }

  String currentMonth() {
    DateTime firstDayCurrentMonth = DateTime(today.year, today.month, 1);
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(firstDayCurrentMonth);
  }

  String currentYear() {
    DateTime firstDayOfYear = DateTime(today.year, 1, 1);
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(firstDayOfYear);
  }

  String twoYearsAgo() {
    DateTime now = DateTime.now();
    DateTime firstDayOfYearTwoYearsAgo = DateTime(now.year - 3, 1, 1);
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(firstDayOfYearTwoYearsAgo);
  }

  String oneMonthAgo() {
    DateTime now = DateTime.now();
    DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(oneMonthAgo);
  }

  String thisMonth() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateFormat dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(firstDayOfMonth);
  }

  String todayYear() {
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateFormat dateFormatter = DateFormat("yyyy");
    return dateFormatter.format(todayDate);
  }

  String todayMonth() {
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateFormat dateFormatter = DateFormat("MM");
    return dateFormatter.format(todayDate);
  }

  String todayDay() {
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateFormat dateFormatter = DateFormat("dd");
    return dateFormatter.format(todayDate);
  }

  formatDate(String date) {
    if (date == "null") {
      return "";
    } else {
      try {
        // print("sdddddddddddddddddddd 1 $date");
        DateTime dateTime = DateFormat("yyyy-MM-dd").parse(date);
        // print("sdddddddddddddddddddd 2 $date");

        String newDate = DateFormat("dd-MM-yyyy").format(dateTime).toString();
        // print("sdddddddddddddddddddd 3$date");

        return newDate;
      } catch (e) {
        return twoYearsAgo();
      }
    }
  }

  formatDateReverse(String date) {
    if (date == "null") {
      return "";
    } else {
      try {
        DateTime dateTime = DateFormat("dd-MM-yyyy").parse(date);
        String newDate = DateFormat("yyyy-MM-dd").format(dateTime).toString();
        return newDate;
      } catch (e) {
        return "null";
      }
    }
  }

  // Function to save selected date
}
