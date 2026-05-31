import 'package:archiving_flutter_project/voice_assistant/assistant_search_field.dart';
import 'package:flutter/material.dart';

class ArchiveVoiceAssistant {
  static bool isArabicUi(Locale locale) => locale.languageCode == 'ar';

  static String welcomeMessage(bool isArabic) => isArabic
      ? 'ماذا تريد أن تبحث عنه في الملفات؟ اختر أحد الخيارات:'
      : 'What do you want to search for in files? Choose an option:';

  static String confirmMessage(
    AssistantSearchField field,
    String value,
    bool isArabic,
  ) {
    final label = fieldInfo(field).label(isArabic);
    return isArabic
        ? 'حسنا، سأفتح استكشاف الملفات وأبحث في "$label" عن: "$value"'
        : 'Okay, opening file explorer and searching "$label" for: "$value"';
  }
}
