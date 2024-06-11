class SearchModel {
  int? page;
  SearchModel({this.page});
  Map<String, dynamic> toJson() {
    return {"page": page};
  }
}
