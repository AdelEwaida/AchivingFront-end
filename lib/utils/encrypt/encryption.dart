import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart'
    as encrypt; // Use a prefix for the encrypt library

class Encryption {
  static String generateRandomKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return keyBytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static String performAesEncryption(
      String data, String keyString, Uint8List ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV(ivString);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(data, iv: iv);

    return encrypted.base64;
  }
}
