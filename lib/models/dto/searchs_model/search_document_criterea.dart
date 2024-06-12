class SearchDocumentCriteria {
  String? key;
  String? desc;
  String? keywords;
  String? ref1;
  String? ref2;
  String? otherRef;
  String? organization;
  String? issueNo;
  String? following;
  int? type;
  String? lastUpdateUser;
  int? vouchType;
  int? vouchNum;
  String? cat;
  String? dept;
  String? usercode;
  String? insurance;
  String? license;
  String? maintenance;
  String? fromIssueDate;
  String? toIssueDate;
  int? page;
  String? searchField;
  int? sortedBy;

  SearchDocumentCriteria({
    this.key,
    this.desc,
    this.keywords,
    this.ref1,
    this.ref2,
    this.otherRef,
    this.organization,
    this.issueNo,
    this.following,
    this.type,
    this.lastUpdateUser,
    this.vouchType,
    this.vouchNum,
    this.cat,
    this.dept,
    this.usercode,
    this.insurance,
    this.license,
    this.maintenance,
    this.fromIssueDate,
    this.toIssueDate,
    this.page = -1,
    this.searchField,
    this.sortedBy,
  });

  factory SearchDocumentCriteria.fromJson(Map<String, dynamic> json) {
    return SearchDocumentCriteria(
      key: json['key'] ?? "",
      desc: json['desc'] ?? "",
      keywords: json['keywords'] ?? "",
      ref1: json['ref1'] ?? "",
      ref2: json['ref2'] ?? "",
      otherRef: json['otherRef'] ?? "",
      organization: json['organization'] ?? "",
      issueNo: json['issueNo'] ?? "",
      following: json['following'] ?? "",
      type: json['type'] ?? -1,
      lastUpdateUser: json['lastUpdateUser'] ?? "",
      vouchType: json['vouchType'] ?? 0,
      vouchNum: json['vouchNum'] ?? 0,
      cat: json['cat'] ?? "",
      dept: json['dept'] ?? "",
      usercode: json['usercode'] ?? "",
      insurance: json['insurance'] ?? "",
      license: json['license'] ?? "",
      maintenance: json['maintenance'] ?? "",
      fromIssueDate: json['fromIssueDate'] ?? "",
      toIssueDate: json['toIssueDate'] ?? "",
      page: json['page'] ?? 1,
      searchField: json['searchField'] ?? "",
      sortedBy: json['sortedBy'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key ?? "",
      'desc': desc ?? "",
      'keywords': keywords ?? "",
      'ref1': ref1 ?? "",
      'ref2': ref2 ?? "",
      'otherRef': otherRef ?? "",
      'organization': organization ?? "",
      'issueNo': issueNo ?? "",
      'following': following ?? "",
      'type': type ?? -1,
      'lastUpdateUser': lastUpdateUser ?? "",
      'vouchType': vouchType ?? -1,
      'vouchNum': vouchNum ?? -1,
      'cat': cat ?? "",
      'dept': dept ?? "",
      'usercode': usercode ?? "",
      'insurance': insurance ?? "",
      'license': license ?? "",
      'maintenance': maintenance ?? "",
      'fromIssueDate': fromIssueDate ?? "",
      'toIssueDate': toIssueDate ?? "",
      'page': page ?? 1,
      'searchField': searchField ?? "",
      'sortedBy': sortedBy ?? -1,
    };
  }
}
