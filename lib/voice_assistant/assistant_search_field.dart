enum AssistantSearchField {
  description,
  issueNo,
  keyword,
  ref1,
  ref2,
  userCode,
}

class AssistantSearchFieldInfo {
  const AssistantSearchFieldInfo({
    required this.field,
    required this.labelAr,
    required this.labelEn,
    required this.valuePromptAr,
    required this.valuePromptEn,
  });

  final AssistantSearchField field;
  final String labelAr;
  final String labelEn;
  final String valuePromptAr;
  final String valuePromptEn;

  String label(bool isArabic) => isArabic ? labelAr : labelEn;
  String valuePrompt(bool isArabic) => isArabic ? valuePromptAr : valuePromptEn;
}

const List<AssistantSearchFieldInfo> kAssistantSearchFields = [
  AssistantSearchFieldInfo(
    field: AssistantSearchField.description,
    labelAr: 'الوصف',
    labelEn: 'Description',
    valuePromptAr: 'اكتب الوصف:',
    valuePromptEn: 'Enter the description:',
  ),
  AssistantSearchFieldInfo(
    field: AssistantSearchField.issueNo,
    labelAr: 'رقم الإشارة',
    labelEn: 'Issue no.',
    valuePromptAr: 'اكتب رقم الإشارة:',
    valuePromptEn: 'Enter the issue number:',
  ),
  AssistantSearchFieldInfo(
    field: AssistantSearchField.keyword,
    labelAr: 'كلمات تعريفية',
    labelEn: 'Keywords',
    valuePromptAr: 'اكتب الكلمات التعريفية:',
    valuePromptEn: 'Enter keywords:',
  ),
  AssistantSearchFieldInfo(
    field: AssistantSearchField.ref1,
    labelAr: 'المرجع 1',
    labelEn: 'Reference 1',
    valuePromptAr: 'اكتب المرجع 1:',
    valuePromptEn: 'Enter reference 1:',
  ),
  AssistantSearchFieldInfo(
    field: AssistantSearchField.ref2,
    labelAr: 'المرجع 2',
    labelEn: 'Reference 2',
    valuePromptAr: 'اكتب المرجع 2:',
    valuePromptEn: 'Enter reference 2:',
  ),
  AssistantSearchFieldInfo(
    field: AssistantSearchField.userCode,
    labelAr: 'كود المستخدم',
    labelEn: 'User code',
    valuePromptAr: 'اكتب كود المستخدم:',
    valuePromptEn: 'Enter the user code:',
  ),
];

AssistantSearchFieldInfo fieldInfo(AssistantSearchField field) {
  return kAssistantSearchFields.firstWhere((e) => e.field == field);
}

class AssistantFileSearchRequest {
  const AssistantFileSearchRequest({
    required this.field,
    required this.value,
  });

  final AssistantSearchField field;
  final String value;
}
