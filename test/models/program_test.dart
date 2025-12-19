import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/data/models/program.dart';

void main() {
  group('Program Model', () {
    test('should create Program with required fields', () {
      final program = Program(
        programName: 'Kursus Flutter',
        programCode: 'KF2024',
        programYear: 2024,
        issueDate: DateTime(2024, 12, 1),
      );

      expect(program.programName, 'Kursus Flutter');
      expect(program.programCode, 'KF2024');
      expect(program.programYear, 2024);
      expect(program.certificateType, 'penyertaan');
      expect(program.templateStyle, 'moden');
      expect(program.language, 'bilingual');
      expect(program.participantCount, 0);
      expect(program.certificateCount, 0);
    });

    test('should create Program with all fields', () {
      final now = DateTime.now();
      final program = Program(
        id: 1,
        programName: 'Kursus Flutter',
        programCode: 'KF2024',
        programYear: 2024,
        certificateType: 'penghargaan',
        templateStyle: 'klasik',
        language: 'malay',
        description: 'Kursus asas Flutter',
        issueDate: DateTime(2024, 12, 1),
        organizer: 'ABC Sdn Bhd',
        organizerTagline: 'Berkhidmat untuk anda',
        logoPath: '/path/to/logo.png',
        signaturePath: '/path/to/signature.png',
        signatoryName: 'Ali bin Abu',
        signatoryTitle: 'Pengarah',
        createdAt: now,
        updatedAt: now,
        participantCount: 50,
        certificateCount: 45,
      );

      expect(program.id, 1);
      expect(program.certificateType, 'penghargaan');
      expect(program.templateStyle, 'klasik');
      expect(program.language, 'malay');
      expect(program.organizer, 'ABC Sdn Bhd');
      expect(program.participantCount, 50);
      expect(program.certificateCount, 45);
    });

    test('should convert Program to Map', () {
      final program = Program(
        programName: 'Kursus Flutter',
        programCode: 'KF2024',
        programYear: 2024,
        issueDate: DateTime(2024, 12, 1),
        organizer: 'ABC Sdn Bhd',
      );

      final map = program.toMap();

      expect(map['program_name'], 'Kursus Flutter');
      expect(map['program_code'], 'KF2024');
      expect(map['program_year'], 2024);
      expect(map['organizer'], 'ABC Sdn Bhd');
      expect(map['certificate_type'], 'penyertaan');
      expect(map['template_style'], 'moden');
    });

    test('should create Program from Map', () {
      final map = {
        'id': 1,
        'program_name': 'Kursus Flutter',
        'program_code': 'KF2024',
        'program_year': 2024,
        'certificate_type': 'penyertaan',
        'template_style': 'moden',
        'language': 'bilingual',
        'issue_date': '2024-12-01T00:00:00.000',
        'organizer': 'ABC Sdn Bhd',
        'participant_count': 10,
        'certificate_count': 5,
      };

      final program = Program.fromMap(map);

      expect(program.id, 1);
      expect(program.programName, 'Kursus Flutter');
      expect(program.programCode, 'KF2024');
      expect(program.organizer, 'ABC Sdn Bhd');
      expect(program.participantCount, 10);
      expect(program.certificateCount, 5);
    });

    test('should handle null values in fromMap', () {
      final map = {
        'id': 1,
        'program_name': 'Kursus Flutter',
        'program_code': 'KF2024',
        'program_year': 2024,
        'issue_date': '2024-12-01T00:00:00.000',
      };

      final program = Program.fromMap(map);

      expect(program.certificateType, 'penyertaan');
      expect(program.templateStyle, 'moden');
      expect(program.language, 'bilingual');
      expect(program.organizer, isNull);
      expect(program.participantCount, 0);
    });

    test('should copy Program with new values', () {
      final program = Program(
        id: 1,
        programName: 'Kursus Flutter',
        programCode: 'KF2024',
        programYear: 2024,
        issueDate: DateTime(2024, 12, 1),
      );

      final copied = program.copyWith(
        programName: 'Kursus Dart',
        organizer: 'XYZ Sdn Bhd',
      );

      expect(copied.id, 1);
      expect(copied.programName, 'Kursus Dart');
      expect(copied.programCode, 'KF2024');
      expect(copied.organizer, 'XYZ Sdn Bhd');
    });

    test('should preserve original values when copyWith has nulls', () {
      final program = Program(
        id: 1,
        programName: 'Kursus Flutter',
        programCode: 'KF2024',
        programYear: 2024,
        issueDate: DateTime(2024, 12, 1),
        organizer: 'ABC Sdn Bhd',
      );

      final copied = program.copyWith();

      expect(copied.id, program.id);
      expect(copied.programName, program.programName);
      expect(copied.organizer, program.organizer);
    });
  });
}
