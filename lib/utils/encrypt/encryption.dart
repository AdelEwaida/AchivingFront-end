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

class EncryptionPass {
  // نفس القيم اللي يستخدمها السيرفر
  static final _key = encrypt.Key.fromUtf8(
      'archiveProj@s2024ASD/Key@team.CT'); // 32 بايت = AES-256
  static final _iv = encrypt.IV(
    Uint8List.fromList([0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1]
        .map((b) => b == 1 ? 0x01 : 0x00)
        .toList()),
  );

  static final _aes = encrypt.Encrypter(
    encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
  );

  static String encryptString(String plain) =>
      _aes.encrypt(plain, iv: _iv).base64;

  static String decryptBase64(String base64Cipher) =>
      _aes.decrypt64(base64Cipher, iv: _iv);
}
