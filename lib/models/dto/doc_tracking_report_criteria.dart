class DocTrackingReportCriteria {
  String? fromDate;
  String? toDate;
  String? status;
  String? dept;

  DocTrackingReportCriteria({
    this.fromDate,
    this.toDate,
    this.status,
    this.dept,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate ?? '',
      'toDate': toDate ?? '',
      'status': status ?? '',
      'dept': dept ?? '',
    };
  }
}
