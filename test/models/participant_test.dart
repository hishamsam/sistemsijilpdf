import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/data/models/participant.dart';

void main() {
  group('Participant Model', () {
    test('should create Participant with required fields', () {
      final participant = Participant(
        programId: 1,
        fullName: 'Ahmad bin Ali',
        icNumber: '901234567890',
      );

      expect(participant.programId, 1);
      expect(participant.fullName, 'Ahmad bin Ali');
      expect(participant.icNumber, '901234567890');
      expect(participant.email, isNull);
      expect(participant.hasCertificate, false);
    });

    test('should create Participant with all fields', () {
      final now = DateTime.now();
      final participant = Participant(
        id: 1,
        programId: 1,
        fullName: 'Ahmad bin Ali',
        icNumber: '901234567890',
        email: 'ahmad@email.com',
        createdAt: now,
        updatedAt: now,
        hasCertificate: true,
      );

      expect(participant.id, 1);
      expect(participant.email, 'ahmad@email.com');
      expect(participant.hasCertificate, true);
    });

    test('should convert Participant to Map', () {
      final participant = Participant(
        id: 1,
        programId: 1,
        fullName: 'Ahmad bin Ali',
        icNumber: '901234567890',
        email: 'ahmad@email.com',
      );

      final map = participant.toMap();

      expect(map['id'], 1);
      expect(map['program_id'], 1);
      expect(map['full_name'], 'Ahmad bin Ali');
      expect(map['ic_number'], '901234567890');
      expect(map['email'], 'ahmad@email.com');
      expect(map['created_at'], isNotNull);
      expect(map['updated_at'], isNotNull);
    });

    test('should create Participant from Map', () {
      final map = {
        'id': 1,
        'program_id': 2,
        'full_name': 'Siti binti Abu',
        'ic_number': '850101125678',
        'email': 'siti@email.com',
        'has_certificate': 1,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final participant = Participant.fromMap(map);

      expect(participant.id, 1);
      expect(participant.programId, 2);
      expect(participant.fullName, 'Siti binti Abu');
      expect(participant.icNumber, '850101125678');
      expect(participant.email, 'siti@email.com');
      expect(participant.hasCertificate, true);
    });

    test('should handle has_certificate = 0 in fromMap', () {
      final map = {
        'id': 1,
        'program_id': 1,
        'full_name': 'Test User',
        'ic_number': '123456789012',
        'has_certificate': 0,
      };

      final participant = Participant.fromMap(map);

      expect(participant.hasCertificate, false);
    });

    test('should handle null has_certificate in fromMap', () {
      final map = {
        'id': 1,
        'program_id': 1,
        'full_name': 'Test User',
        'ic_number': '123456789012',
      };

      final participant = Participant.fromMap(map);

      expect(participant.hasCertificate, false);
    });

    test('should copy Participant with new values', () {
      final participant = Participant(
        id: 1,
        programId: 1,
        fullName: 'Ahmad bin Ali',
        icNumber: '901234567890',
      );

      final copied = participant.copyWith(
        fullName: 'Ahmad bin Abu',
        email: 'ahmad@newemail.com',
        hasCertificate: true,
      );

      expect(copied.id, 1);
      expect(copied.fullName, 'Ahmad bin Abu');
      expect(copied.icNumber, '901234567890');
      expect(copied.email, 'ahmad@newemail.com');
      expect(copied.hasCertificate, true);
    });

    test('should preserve original values when copyWith has no changes', () {
      final participant = Participant(
        id: 1,
        programId: 1,
        fullName: 'Ahmad bin Ali',
        icNumber: '901234567890',
        email: 'ahmad@email.com',
      );

      final copied = participant.copyWith();

      expect(copied.id, participant.id);
      expect(copied.programId, participant.programId);
      expect(copied.fullName, participant.fullName);
      expect(copied.email, participant.email);
    });
  });
}
