import '../../../models/db/scanned_image.dart';

class ScanResult {
  final int statusCode;
  final ScannedImage? scannedImage;

  ScanResult({
    required this.statusCode,
    this.scannedImage,
  });
}
