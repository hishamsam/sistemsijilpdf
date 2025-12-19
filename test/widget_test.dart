import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/data/models/program.dart';
import 'package:sistem_sijil/data/models/participant.dart';
import 'package:sistem_sijil/data/models/certificate.dart';

void main() {
  group('App Smoke Tests', () {
    test('Program model can be instantiated', () {
      final program = Program(
        programName: 'Test',
        programCode: 'TEST001',
        programYear: 2024,
        issueDate: DateTime.now(),
      );
      expect(program, isNotNull);
    });

    test('Participant model can be instantiated', () {
      final participant = Participant(
        programId: 1,
        fullName: 'Test User',
        icNumber: '123456789012',
      );
      expect(participant, isNotNull);
    });

    test('Certificate model can be instantiated', () {
      final certificate = Certificate(
        participantId: 1,
        uniqueCode: 'UNIQUE001',
        certificateNumber: 'CERT-001',
      );
      expect(certificate, isNotNull);
    });
  });
}
