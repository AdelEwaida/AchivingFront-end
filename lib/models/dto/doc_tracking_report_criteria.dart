class DocTrackingReportCriteria {
  String? fromDate;
  String? toDate;
  int? status;
  String? deptKey;

  DocTrackingReportCriteria({
    this.fromDate,
    this.toDate,
    this.status,
    this.deptKey,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'fromDate': fromDate ?? '',
      'toDate': toDate ?? '',
      'deptKey': deptKey ?? '',
    };
    if (status != null) {
      data['status'] = status;
    }
    return data;
  }
}
