import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/utils/crypto_utils.dart';
import '../data/models/certificate.dart';
import '../data/models/participant.dart';
import '../data/models/program.dart';

class QrService {
  /// Generate QR data - returns URL if verificationUrl is provided, otherwise JSON
  String generateQrData({
    required Certificate certificate,
    required Participant participant,
    required Program program,
    required String secretKey,
    String? verificationUrl,
  }) {
    // If verification URL is set, generate URL-based QR
    if (verificationUrl != null && verificationUrl.isNotEmpty) {
      return generateVerificationUrl(verificationUrl, certificate.certificateNumber);
    }
    
    // Otherwise, generate JSON data (legacy mode)
    final data = {
      'v': 1,
      'code': certificate.uniqueCode,
      'name': participant.fullName,
      'ic': CryptoUtils.maskIcNumber(participant.icNumber),
      'prog': program.programName,
      'date': program.issueDate.toIso8601String().split('T')[0],
      'cert': certificate.certificateNumber,
    };

    final signature = CryptoUtils.generateSignature(data, secretKey);
    data['sig'] = signature;

    return jsonEncode(data);
  }

  /// Generate verification URL for QR code
  String generateVerificationUrl(String baseUrl, String certificateNumber) {
    // Clean up URL - remove trailing slash if any
    String url = baseUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    
    // Add certificate number as query parameter
    final encodedCert = Uri.encodeComponent(certificateNumber);
    return '$url?cert=$encodedCert';
  }

  Map<String, dynamic>? parseQrData(String qrData) {
    try {
      return jsonDecode(qrData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool verifyQrData(Map<String, dynamic> qrData, String secretKey) {
    return CryptoUtils.verifySignature(qrData, secretKey);
  }

  Future<Uint8List> generateQrImage(String data, {double size = 200}) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('QR data validation failed');
    }

    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: true,
    );

    final image = await painter.toImage(size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
