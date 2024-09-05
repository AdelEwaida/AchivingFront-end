import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Converters {
  formateDouble(double a) {
    final double formattedValue = a;
    final NumberFormat formatter =
        NumberFormat('0.00'); // Format with two digits after point
    return double.parse(formatter.format(formattedValue));
  }

  formateEqvDouble(double a) {
    final double formattedValue = a;
    final NumberFormat formatter =
        NumberFormat('0000.00'); // Format with two digits after point
    return double.parse(formatter.format(formattedValue));
  }

  static TimeOfDay? parseTimeOfDay(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  static formatNumber(double num) {
    NumberFormat myFormat = NumberFormat("#.##");
    return myFormat.format(num);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Format DateTime to desired string format
    final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
    return formattedTime;
  }

  static formatNumber2(double num) {
    NumberFormat myFormat = NumberFormat("#.###");
    return myFormat.format(num);
  }

  static String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return dateString; // Return original string if parsing fails
    }
  }

  static String getDateBeforeMonth() {
    DateTime currentDate = DateTime.now();
    DateTime? dateBeforeOneMonth;
    dateBeforeOneMonth = currentDate.subtract(const Duration(days: 30));

    return formatDate2(dateBeforeOneMonth.toString());
  }

  static String getYesterdayDate() {
    // Get the current date and time
    DateTime currentDate = DateTime.now();

    // Subtract one day to get yesterday's date
    DateTime yesterdayDate = currentDate.subtract(const Duration(days: 1));

    // Format the date as desired (optional)
    return formatDate2(yesterdayDate.toString());
  }

  static String getBeforeMontheSinceYesterday() {
    // Get the current date and time
    DateTime currentDate = DateTime.now();

    // Subtract one day to get yesterday's date
    DateTime yesterdayDate = currentDate.subtract(const Duration(days: 1));
    DateTime? dateBeforeOneMonthSinceYesterDay;
    dateBeforeOneMonthSinceYesterDay =
        yesterdayDate.subtract(const Duration(days: 30));

    // Format the date as desired (optional)
    return formatDate2(dateBeforeOneMonthSinceYesterDay.toString());
  }

  static String replaceArabicNumbers(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabicNumerals.length; i++) {
      input = input.replaceAll(arabicNumerals[i], englishNumerals[i]);
    }
    return input;
  }

  static String formatDate2(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      return formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return dateString; // Return original string if parsing fails
    }
  }

  static String getFormattedDateSimple(int time) {
    DateFormat newFormat = DateFormat("MMMM dd, yyyy");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  static String startOfCurrentYearAsString() {
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(now.year, 1, 1);
    return DateFormat('yyyy-MM-dd').format(startOfYear);
  }

  String replaceArabicWithEnglish(String input) {
    final Map<String, String> arabicToEnglishMap = {
      'ش': 'a',
      'لا': 'b',
      'ؤ': 'c',
      'ي': 'd',
      'ث': 'e',
      'ب': 'f',
      'ل': 'g',
      'ا': 'h',
      'ه': 'i',
      'ت': 'j',
      'ن': 'k',
      'م': 'l',
      'ة': 'm',
      'ى': 'n',
      'خ': 'o',
      'ح': 'p',
      'ض': 'q',
      'ق': 'r',
      'س': 's',
      'ف': 't',
      'ع': 'u',
      'ر': 'v',
      'ص': 'w',
      'ء': 'x',
      'غ': 'y',
      'ئ': 'z',
      'ِ': 'A',
      'لآ': 'B',
      '}': 'C',
      ']': 'D',
      'ُ': 'E',
      '[]': 'F',
      'لأ': 'G',
      'أ': 'H',
      '÷': 'I',
      'ـ': 'J',
      '،': 'K',
      '/': 'L',
      '’': 'M',
      'آ': 'N',
      '×': 'O',
      '؛': 'P',
      'َ': 'Q',
      'ٌ': 'R',
      'ٍ': 'S',
      'لإ': 'T',
      '‘': 'U',
      '{}': 'V',
      'ً': 'W',
      'ْ': 'X',
      'إ': 'Y',
      '~': 'Z',
    };

    String result = '';
    int i = 0;

    while (i < input.length) {
      String currentChar = input[i];
      String nextTwoChars =
          i + 1 < input.length ? input.substring(i, i + 2) : '';
      if (arabicToEnglishMap.containsKey(nextTwoChars)) {
        result += arabicToEnglishMap[nextTwoChars]!;
        i += 2;
      } else if (arabicToEnglishMap.containsKey(currentChar)) {
        result += arabicToEnglishMap[currentChar]!;
        i++;
      } else {
        result += currentChar;
        i++;
      }
    }
    return result;
  }

  static String converTime(TimeOfDay time) {
    String hour = time.hour.toString();
    String minutes = time.minute.toString();
    if (hour.length == 1) {
      hour = "0$hour";
    }

    if (minutes.length == 1) {
      minutes = "0$minutes";
    }

    return "$hour:$minutes:00";
  }

  static String getDateFromDateTime(String dateTime) {
    return dateTime.substring(0, dateTime.indexOf(" "));
  }
}
