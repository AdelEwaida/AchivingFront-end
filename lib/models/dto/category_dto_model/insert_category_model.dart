class InsertCategoryModel {
  String? id;
  String? shortCode;
  String? description;
  String? deptCode;

  InsertCategoryModel({
    this.id,
    this.shortCode,
    this.description,
    this.deptCode,
  });

  // Factory constructor to create an instance from a JSON map
  factory InsertCategoryModel.fromJson(Map<String, dynamic> json) {
    return InsertCategoryModel(
      id: json['id'],
      shortCode: json['shortCode'],
      description: json['description'],
      deptCode: json['deptCode'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortCode': shortCode,
      'description': description,
      'deptCode': deptCode,
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'shortCode': shortCode,
    };
  }
}
