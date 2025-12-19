import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/data/models/certificate.dart';

void main() {
  group('Certificate Model', () {
    test('should create Certificate with required fields', () {
      final certificate = Certificate(
        participantId: 1,
        uniqueCode: 'ABC123',
        certificateNumber: 'CERT-2024-001',
      );

      expect(certificate.participantId, 1);
      expect(certificate.uniqueCode, 'ABC123');
      expect(certificate.certificateNumber, 'CERT-2024-001');
      expect(certificate.isVerified, false);
      expect(certificate.verificationCount, 0);
    });

    test('should create Certificate with all fields', () {
      final now = DateTime.now();
      final certificate = Certificate(
        id: 1,
        participantId: 1,
        uniqueCode: 'ABC123',
        certificateNumber: 'CERT-2024-001',
        pdfPath: '/path/to/cert.pdf',
        qrData: 'encoded_qr_data',
        verificationHash: 'hash123',
        isVerified: true,
        verificationCount: 5,
        lastVerifiedAt: now,
        generatedAt: now,
        createdAt: now,
        updatedAt: now,
        participantName: 'Ahmad bin Ali',
        programName: 'Kursus Flutter',
      );

      expect(certificate.id, 1);
      expect(certificate.pdfPath, '/path/to/cert.pdf');
      expect(certificate.isVerified, true);
      expect(certificate.verificationCount, 5);
      expect(certificate.participantName, 'Ahmad bin Ali');
      expect(certificate.programName, 'Kursus Flutter');
    });

    test('should convert Certificate to Map', () {
      final certificate = Certificate(
        id: 1,
        participantId: 1,
        uniqueCode: 'ABC123',
        certificateNumber: 'CERT-2024-001',
        isVerified: true,
        verificationCount: 3,
      );

      final map = certificate.toMap();

      expect(map['id'], 1);
      expect(map['participant_id'], 1);
      expect(map['unique_code'], 'ABC123');
      expect(map['certificate_number'], 'CERT-2024-001');
      expect(map['is_verified'], 1);
      expect(map['verification_count'], 3);
    });

    test('should convert isVerified false to 0 in toMap', () {
      final certificate = Certificate(
        participantId: 1,
        uniqueCode: 'ABC123',
        certificateNumber: 'CERT-2024-001',
        isVerified: false,
      );

      final map = certificate.toMap();

      expect(map['is_verified'], 0);
    });

    test('should create Certificate from Map', () {
      final map = {
        'id': 1,
        'participant_id': 2,
        'unique_code': 'XYZ789',
        'certificate_number': 'CERT-2024-002',
        'pdf_path': '/path/to/cert.pdf',
        'qr_data': 'qr_data_here',
        'verification_hash': 'hash_value',
        'is_verified': 1,
        'verification_count': 10,
        'last_verified_at': '2024-12-01T10:00:00.000',
        'generated_at': '2024-11-01T10:00:00.000',
        'created_at': '2024-11-01T09:00:00.000',
        'updated_at': '2024-12-01T10:00:00.000',
        'participant_name': 'Siti binti Abu',
        'program_name': 'Kursus Dart',
      };

      final certificate = Certificate.fromMap(map);

      expect(certificate.id, 1);
      expect(certificate.participantId, 2);
      expect(certificate.uniqueCode, 'XYZ789');
      expect(certificate.isVerified, true);
      expect(certificate.verificationCount, 10);
      expect(certificate.participantName, 'Siti binti Abu');
      expect(certificate.programName, 'Kursus Dart');
    });

    test('should handle is_verified = 0 in fromMap', () {
      final map = {
        'id': 1,
        'participant_id': 1,
        'unique_code': 'ABC123',
        'certificate_number': 'CERT-001',
        'is_verified': 0,
      };

      final certificate = Certificate.fromMap(map);

      expect(certificate.isVerified, false);
    });

    test('should handle null dates in fromMap', () {
      final map = {
        'id': 1,
        'participant_id': 1,
        'unique_code': 'ABC123',
        'certificate_number': 'CERT-001',
      };

      final certificate = Certificate.fromMap(map);

      expect(certificate.lastVerifiedAt, isNull);
      expect(certificate.generatedAt, isNull);
      expect(certificate.createdAt, isNull);
    });

    test('should copy Certificate with new values', () {
      final certificate = Certificate(
        id: 1,
        participantId: 1,
        uniqueCode: 'ABC123',
        certificateNumber: 'CERT-2024-001',
        isVerified: false,
        verificationCount: 0,
      );

      final copied = certificate.copyWith(
        isVerified: true,
        verificationCount: 5,
        pdfPath: '/new/path.pdf',
      );

      expect(copied.id, 1);
      expect(copied.uniqueCode, 'ABC123');
      expect(copied.isVerified, true);
      expect(copied.verificationCount, 5);
      expect(copied.pdfPath, '/new/path.pdf');
    });

    test('should preserve original values when copyWith has no changes', () {
      final certificate = Certificate(
        id: 1,
        participantId: 1,
        uniqueCode: 'ABC123',
        certificateNumber: 'CERT-2024-001',
        pdfPath: '/original/path.pdf',
      );

      final copied = certificate.copyWith();

      expect(copied.id, certificate.id);
      expect(copied.uniqueCode, certificate.uniqueCode);
      expect(copied.pdfPath, certificate.pdfPath);
    });
  });
}
