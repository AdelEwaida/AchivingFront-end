class CountModel {
  int? count;

  CountModel({this.count});

  factory CountModel.fromJson(Map<String, dynamic> json) {
    return CountModel(
        count: json['count'].toString() == "null" ? 0 : json['count']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cont'] = count;
    return data;
  }
}
