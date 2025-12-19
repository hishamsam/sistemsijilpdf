import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String generateSignature(Map<String, dynamic> data, String secretKey) {
    final payload = "${data['code']}|${data['name']}|${data['cert']}";
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final digest = hmac.convert(utf8.encode(payload));
    return base64.encode(digest.bytes);
  }

  static bool verifySignature(Map<String, dynamic> qrData, String secretKey) {
    final expectedSig = generateSignature(qrData, secretKey);
    return qrData['sig'] == expectedSig;
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  static String maskIcNumber(String icNumber) {
    if (icNumber.length < 6) return icNumber;
    final visible = icNumber.substring(0, 6);
    final masked = '*' * (icNumber.length - 6);
    return '$visible$masked';
  }
}
