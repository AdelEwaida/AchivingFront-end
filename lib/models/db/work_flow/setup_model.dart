class SetupModel {
  final String? txtPropertyname;
  final String? description;
  final int? bolActive;
  final String? arDescription;

  SetupModel({
    this.txtPropertyname,
    this.description,
    this.bolActive,
    this.arDescription,
  });

  factory SetupModel.fromJson(Map<String, dynamic> json) {
    return SetupModel(
      txtPropertyname: json['txtPropertyname'],
      description: json['description'],
      bolActive: json['bolActive'],
      arDescription: json['arDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtPropertyname': txtPropertyname,
      'description': description,
      'bolActive': bolActive,
      'arDescription': arDescription,
    };
  }

  @override
  String toString() {
    return description.toString();
  }
}
