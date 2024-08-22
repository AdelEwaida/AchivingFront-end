class ReportsCriteria {
  String? fromDate;
  String? toDate;
  String? cat;
  String? dept;

  ReportsCriteria({this.cat, this.fromDate, this.dept, this.toDate});
  Map<String, dynamic> toJson() {
    return {"cat": cat, "fromDate": fromDate, "dept": dept, "toDate": toDate};
  }
}
