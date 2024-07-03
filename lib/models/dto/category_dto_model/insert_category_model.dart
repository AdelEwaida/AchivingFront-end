class InsertCategoryModel {
  String? id;
  String? shortCode;
  String? description;
  String? deptCode;
  String? txtReference;
  InsertCategoryModel({
    this.id,
    this.shortCode,
    this.description,
    this.deptCode,
      this.txtReference
  });

  // Factory constructor to create an instance from a JSON map
  factory InsertCategoryModel.fromJson(Map<String, dynamic> json) {
    return InsertCategoryModel(
      id: json['id'],
      shortCode: json['shortCode'],
      description: json['description'],
      deptCode: json['deptCode'],
        txtReference: json['txtReference']
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortCode': shortCode,
      'description': description,
      'deptCode': deptCode,
      'txtReference': txtReference
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'shortCode': shortCode,
    };
  }
}
