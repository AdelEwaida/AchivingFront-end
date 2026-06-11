import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class FileBarcodeUtils {
  static const int defaultDigitLength = 8;
  static const int maxEightDigitValue = 99999999;

  static int digitLengthFor(int sequence) {
    if (sequence <= maxEightDigitValue) return defaultDigitLength;
    return sequence.toString().length;
  }

  static String formatSequence(int sequence) {
    return sequence.toString().padLeft(digitLengthFor(sequence), '0');
  }

  static Future<String> allocateNext(FlutterSecureStorage storage) async {
    final raw = await storage.read(key: StorageKeys.fileBarcodeSequence);
    final current = int.tryParse(raw ?? '0') ?? 0;
    final next = current + 1;
    await storage.write(
      key: StorageKeys.fileBarcodeSequence,
      value: next.toString(),
    );
    return formatSequence(next);
  }
}
