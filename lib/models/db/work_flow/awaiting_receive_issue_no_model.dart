class AwaitingReceiveIssueNoModel {
  AwaitingReceiveIssueNoModel({
    this.issueNo,
    this.documentKey,
    this.documentDescription,
  });

  final String? issueNo;
  final String? documentKey;
  final String? documentDescription;

  factory AwaitingReceiveIssueNoModel.fromJson(Map<String, dynamic> json) {
    return AwaitingReceiveIssueNoModel(
      issueNo: json['issueNo']?.toString() ?? '',
      documentKey: json['documentKey']?.toString() ?? '',
      documentDescription: json['documentDescription']?.toString() ?? '',
    );
  }

  static List<AwaitingReceiveIssueNoModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) =>
            AwaitingReceiveIssueNoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String get displayLabel {
    final no = (issueNo ?? '').trim();
    final desc = (documentDescription ?? '').trim();
    if (no.isEmpty && desc.isEmpty) return '';
    if (desc.isEmpty) return no;
    if (no.isEmpty) return desc;
    return '$no — $desc';
  }

  @override
  String toString() => displayLabel;
}
