class ScannersModel {
  List<String>? scanners;

  ScannersModel({this.scanners});

  // Factory constructor to create an instance from a JSON map
  factory ScannersModel.fromJson(Map<String, dynamic> json) {
    return ScannersModel(
      scanners:
          json['scanners'] != null ? List<String>.from(json['scanners']) : null,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'scanners': scanners,
    };
  }
  // @override
  // String toString() {
  //   // TODO: implement toString
  //   return scanners;
  // }
}
