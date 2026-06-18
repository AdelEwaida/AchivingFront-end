class DocTrackingReportCriteria {
  String? fromDate;
  String? toDate;
  int? status;
  String? deptKey;
  int? page;

  DocTrackingReportCriteria({
    this.fromDate,
    this.toDate,
    this.status,
    this.deptKey,
    this.page,
  });

  Map<String, dynamic> toJson({bool includePage = true}) {
    final data = <String, dynamic>{
      'fromDate': fromDate ?? '',
      'toDate': toDate ?? '',
      'deptKey': deptKey ?? '',
    };
    if (status != null) {
      data['status'] = status;
    }
    if (includePage && page != null) {
      data['page'] = page;
    }
    return data;
  }
}
