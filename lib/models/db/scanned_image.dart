class ScannedImage {
  String? scannedImage;

  ScannedImage({this.scannedImage});

  // Factory constructor to create an instance from a JSON map
  factory ScannedImage.fromJson(Map<String, dynamic> json) {
    return ScannedImage(
      scannedImage: json['scannedImage'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'scannedImage': scannedImage,
    };
  }
}
