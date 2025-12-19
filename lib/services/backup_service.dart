import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import '../data/repositories/program_repository.dart';
import '../data/repositories/participant_repository.dart';
import '../data/repositories/certificate_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/models/program.dart';
import '../data/models/participant.dart';
import '../data/models/certificate.dart';

class BackupService {
  final ProgramRepository _programRepo = ProgramRepository();
  final ParticipantRepository _participantRepo = ParticipantRepository();
  final CertificateRepository _certificateRepo = CertificateRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  Future<File?> createBackup() async {
    final programs = await _programRepo.getAll();
    final allParticipants = <Participant>[];
    final allCertificates = <Certificate>[];

    for (final program in programs) {
      final participants = await _participantRepo.getByProgramId(program.id!);
      allParticipants.addAll(participants);
      
      final certificates = await _certificateRepo.getByProgramId(program.id!);
      allCertificates.addAll(certificates);
    }

    final settings = await _settingsRepo.getAll();

    final backupData = {
      'version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'programs': programs.map((p) => p.toMap()).toList(),
      'participants': allParticipants.map((p) => p.toMap()).toList(),
      'certificates': allCertificates.map((c) => c.toMap()).toList(),
      'settings': settings,
    };

    final jsonData = jsonEncode(backupData);

    final saveResult = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Backup',
      fileName: 'backup_sijil_${DateTime.now().millisecondsSinceEpoch}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (saveResult == null) return null;

    final file = File(saveResult);
    await file.writeAsString(jsonData);
    return file;
  }

  Future<Map<String, dynamic>?> loadBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.single.path!);
    final jsonData = await file.readAsString();
    return jsonDecode(jsonData) as Map<String, dynamic>;
  }

  Future<bool> restoreBackup(Map<String, dynamic> backupData) async {
    try {
      final programsData = backupData['programs'] as List<dynamic>;
      final participantsData = backupData['participants'] as List<dynamic>;
      final certificatesData = backupData['certificates'] as List<dynamic>;
      final settingsData = backupData['settings'] as Map<String, dynamic>?;

      final programIdMap = <int, int>{};
      for (final pData in programsData) {
        final oldId = pData['id'] as int;
        final program = Program.fromMap(pData as Map<String, dynamic>);
        final newId = await _programRepo.insert(program);
        programIdMap[oldId] = newId;
      }

      final participantIdMap = <int, int>{};
      for (final pData in participantsData) {
        final oldId = pData['id'] as int;
        final oldProgramId = pData['program_id'] as int;
        final newProgramId = programIdMap[oldProgramId];
        if (newProgramId == null) continue;

        final participant = Participant.fromMap(pData as Map<String, dynamic>)
            .copyWith(programId: newProgramId);
        final newId = await _participantRepo.insert(participant);
        participantIdMap[oldId] = newId;
      }

      for (final cData in certificatesData) {
        final oldParticipantId = cData['participant_id'] as int;
        final newParticipantId = participantIdMap[oldParticipantId];
        if (newParticipantId == null) continue;

        final certificate = Certificate.fromMap(cData as Map<String, dynamic>)
            .copyWith(participantId: newParticipantId);
        await _certificateRepo.insert(certificate);
      }

      if (settingsData != null) {
        for (final entry in settingsData.entries) {
          if (entry.key != 'app_password_hash') {
            await _settingsRepo.set(entry.key, entry.value as String);
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<File?> exportCertificatesZip(int programId) async {
    final certificates = await _certificateRepo.getByProgramId(programId);
    if (certificates.isEmpty) return null;

    final archive = Archive();

    for (final cert in certificates) {
      if (cert.pdfPath != null) {
        final file = File(cert.pdfPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(
            '${cert.certificateNumber}.pdf',
            bytes.length,
            bytes,
          ));
        }
      }
    }

    if (archive.isEmpty) return null;

    final saveResult = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan ZIP',
      fileName: 'certificates_${DateTime.now().millisecondsSinceEpoch}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (saveResult == null) return null;

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) return null;

    final file = File(saveResult);
    await file.writeAsBytes(zipBytes);
    return file;
  }
}
