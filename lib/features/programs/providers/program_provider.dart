import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/program.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/certificate.dart';
import '../../../data/repositories/program_repository.dart';
import '../../../data/repositories/participant_repository.dart';
import '../../../data/repositories/certificate_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../services/pdf_service.dart';
import '../../../services/qr_service.dart';
import '../../../services/excel_service.dart';
import '../../../services/auto_csv_service.dart';
import '../../template_editor/repositories/custom_template_repository.dart';
import '../../template_editor/services/template_pdf_service.dart';

class ProgramProvider extends ChangeNotifier {
  final ProgramRepository _programRepo = ProgramRepository();
  final ParticipantRepository _participantRepo = ParticipantRepository();
  final CertificateRepository _certificateRepo = CertificateRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final PdfService _pdfService = PdfService();
  final QrService _qrService = QrService();
  final ExcelService _excelService = ExcelService();
  final AutoCsvService _autoCsvService = AutoCsvService();
  final CustomTemplateRepository _customTemplateRepo = CustomTemplateRepository();
  final TemplatePdfService _templatePdfService = TemplatePdfService();
  final Uuid _uuid = const Uuid();

  List<Program> _programs = [];
  List<Participant> _participants = [];
  Program? _selectedProgram;
  bool _isLoading = false;
  String? _error;
  int _totalCertificates = 0;

  List<Program> get programs => _programs;
  List<Participant> get participants => _participants;
  Program? get selectedProgram => _selectedProgram;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCertificates => _totalCertificates;

  Future<void> loadPrograms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _programs = await _programRepo.getAll();
      _totalCertificates = await _certificateRepo.getCount();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadParticipants(int programId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _participants = await _participantRepo.getByProgramId(programId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectProgram(int programId) async {
    _selectedProgram = await _programRepo.getById(programId);
    await loadParticipants(programId);
    notifyListeners();
  }

  Future<int> createProgram(Program program) async {
    final id = await _programRepo.insert(program);
    await loadPrograms();
    return id;
  }

  Future<void> updateProgram(Program program) async {
    // Check if certificate-related fields changed
    final oldProgram = await _programRepo.getById(program.id!);
    bool needsRegenerate = false;
    
    if (oldProgram != null) {
      needsRegenerate = oldProgram.certificateType != program.certificateType ||
          oldProgram.templateStyle != program.templateStyle ||
          oldProgram.language != program.language ||
          oldProgram.customTemplateId != program.customTemplateId ||
          oldProgram.showIcNumber != program.showIcNumber ||
          oldProgram.signatoryName != program.signatoryName ||
          oldProgram.signatoryTitle != program.signatoryTitle ||
          oldProgram.signatoryName2 != program.signatoryName2 ||
          oldProgram.signatoryTitle2 != program.signatoryTitle2 ||
          oldProgram.signatoryName3 != program.signatoryName3 ||
          oldProgram.signatoryTitle3 != program.signatoryTitle3 ||
          oldProgram.signaturePath != program.signaturePath ||
          oldProgram.signaturePath2 != program.signaturePath2 ||
          oldProgram.signaturePath3 != program.signaturePath3 ||
          oldProgram.logoPath != program.logoPath ||
          oldProgram.organizer != program.organizer ||
          oldProgram.organizerTagline != program.organizerTagline ||
          oldProgram.programName != program.programName;
    }
    
    await _programRepo.update(program);
    
    // If certificate-related fields changed, invalidate existing certificates
    if (needsRegenerate) {
      await _certificateRepo.clearPdfPathsByProgramId(program.id!);
    }
    
    await loadPrograms();
    if (_selectedProgram?.id == program.id) {
      _selectedProgram = await _programRepo.getById(program.id!);
      notifyListeners();
    }
  }

  Future<void> deleteProgram(int id) async {
    await _programRepo.delete(id);
    if (_selectedProgram?.id == id) {
      _selectedProgram = null;
      _participants = [];
    }
    await loadPrograms();
  }

  Future<int> addParticipant(Participant participant) async {
    final id = await _participantRepo.insert(participant);
    await loadParticipants(participant.programId);
    return id;
  }

  Future<void> updateParticipant(Participant participant) async {
    await _participantRepo.update(participant);
    await loadParticipants(participant.programId);
  }

  Future<void> deleteParticipant(int id, int programId) async {
    await _participantRepo.delete(id);
    await loadParticipants(programId);
  }

  Future<int> importParticipants(int programId) async {
    final participants = await _excelService.importFromExcel(programId);
    if (participants.isEmpty) return 0;

    int count = 0;
    for (final participant in participants) {
      final exists = await _participantRepo.icExistsInProgram(
        participant.icNumber,
        programId,
      );
      if (!exists) {
        await _participantRepo.insert(participant);
        count++;
      }
    }

    await loadParticipants(programId);
    return count;
  }

  Future<Uint8List?> generateCertificate(Participant participant, {bool forceRegenerate = false}) async {
    if (_selectedProgram == null) return null;

    final existingCert = await _certificateRepo.getByParticipantId(participant.id!);
    if (existingCert != null && !forceRegenerate) {
      if (existingCert.pdfPath != null) {
        final file = File(existingCert.pdfPath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    }

    final secretKey = await _settingsRepo.getSecretKey();
    final verificationUrl = await _settingsRepo.getVerificationUrl();
    final certNumber = await _certificateRepo.generateCertificateNumber(
      _selectedProgram!.programCode,
      _selectedProgram!.programYear,
    );
    final uniqueCode = _uuid.v4();

    final certificate = Certificate(
      participantId: participant.id!,
      uniqueCode: uniqueCode,
      certificateNumber: certNumber,
      generatedAt: DateTime.now(),
    );

    final qrData = _qrService.generateQrData(
      certificate: certificate,
      participant: participant,
      program: _selectedProgram!,
      secretKey: secretKey,
      verificationUrl: verificationUrl,
    );

    final qrImage = await _qrService.generateQrImage(qrData);

    Uint8List? logoImage;
    Uint8List? signatureImage;
    Uint8List? signatureImage2;
    Uint8List? signatureImage3;

    if (_selectedProgram!.logoPath != null) {
      final logoFile = File(_selectedProgram!.logoPath!);
      if (await logoFile.exists()) {
        logoImage = await logoFile.readAsBytes();
      }
    }

    if (_selectedProgram!.signaturePath != null) {
      final sigFile = File(_selectedProgram!.signaturePath!);
      if (await sigFile.exists()) {
        signatureImage = await sigFile.readAsBytes();
      }
    }

    if (_selectedProgram!.signaturePath2 != null) {
      final sigFile2 = File(_selectedProgram!.signaturePath2!);
      if (await sigFile2.exists()) {
        signatureImage2 = await sigFile2.readAsBytes();
      }
    }

    if (_selectedProgram!.signaturePath3 != null) {
      final sigFile3 = File(_selectedProgram!.signaturePath3!);
      if (await sigFile3.exists()) {
        signatureImage3 = await sigFile3.readAsBytes();
      }
    }

    Uint8List pdfBytes;
    
    // Check if using custom template
    if (_selectedProgram!.customTemplateId != null) {
      final customTemplate = await _customTemplateRepo.getById(_selectedProgram!.customTemplateId!);
      if (customTemplate != null) {
        pdfBytes = await _templatePdfService.generateFromTemplate(
          template: customTemplate,
          certificate: certificate,
          participant: participant,
          program: _selectedProgram!,
          qrCodeImage: qrImage,
          logoImage: logoImage,
          signatureImage: signatureImage,
          signatureImage2: signatureImage2,
          signatureImage3: signatureImage3,
        );
      } else {
        pdfBytes = await _pdfService.generateCertificate(
          certificate: certificate,
          participant: participant,
          program: _selectedProgram!,
          qrCodeImage: qrImage,
          logoImage: logoImage,
          signatureImage: signatureImage,
          signatureImage2: signatureImage2,
          signatureImage3: signatureImage3,
        );
      }
    } else {
      pdfBytes = await _pdfService.generateCertificate(
        certificate: certificate,
        participant: participant,
        program: _selectedProgram!,
        qrCodeImage: qrImage,
        logoImage: logoImage,
        signatureImage: signatureImage,
        signatureImage2: signatureImage2,
        signatureImage3: signatureImage3,
      );
    }

    final pdfFile = await _pdfService.savePdf(
      pdfBytes,
      '${certificate.certificateNumber}.pdf',
    );

    final certToSave = certificate.copyWith(
      pdfPath: pdfFile.path,
      qrData: qrData,
    );

    if (existingCert != null) {
      await _certificateRepo.update(certToSave.copyWith(id: existingCert.id));
    } else {
      await _certificateRepo.insert(certToSave);
      _totalCertificates = await _certificateRepo.getCount();
    }

    // Auto-update CSV for online verification
    await _autoCsvService.updateCsvFile();

    await loadParticipants(_selectedProgram!.id!);
    notifyListeners();
    return pdfBytes;
  }

  Future<int> generateAllCertificates({Function(int, int)? onProgress}) async {
    if (_selectedProgram == null) return 0;

    final participants = await _participantRepo.getByProgramId(_selectedProgram!.id!);
    int count = 0;

    for (int i = 0; i < participants.length; i++) {
      await generateCertificate(participants[i]);
      count++;
      onProgress?.call(count, participants.length);
    }

    await loadParticipants(_selectedProgram!.id!);
    return count;
  }

  Future<int> regenerateAllCertificates({
    List<Participant>? selectedParticipants,
    Function(int, int)? onProgress,
  }) async {
    if (_selectedProgram == null) return 0;

    final participants = selectedParticipants ?? 
        await _participantRepo.getByProgramId(_selectedProgram!.id!);
    
    // Filter only participants with existing certificates
    final participantsWithCerts = <Participant>[];
    for (final p in participants) {
      final cert = await _certificateRepo.getByParticipantId(p.id!);
      if (cert != null) {
        participantsWithCerts.add(p);
      }
    }

    int count = 0;
    for (int i = 0; i < participantsWithCerts.length; i++) {
      await generateCertificate(participantsWithCerts[i], forceRegenerate: true);
      count++;
      onProgress?.call(count, participantsWithCerts.length);
    }

    await loadParticipants(_selectedProgram!.id!);
    return count;
  }

  Future<List<Program>> searchPrograms(String query) async {
    return await _programRepo.search(query);
  }

  Future<List<Participant>> searchParticipants(String query, {int? programId}) async {
    return await _participantRepo.search(query, programId: programId);
  }

  Future<Uint8List?> generateCombinedPdf(List<Participant> participants) async {
    if (_selectedProgram == null || participants.isEmpty) return null;

    final secretKey = await _settingsRepo.getSecretKey();
    final verificationUrl = await _settingsRepo.getVerificationUrl();
    
    Uint8List? logoImage;
    Uint8List? signatureImage;
    Uint8List? signatureImage2;
    Uint8List? signatureImage3;

    if (_selectedProgram!.logoPath != null) {
      final logoFile = File(_selectedProgram!.logoPath!);
      if (await logoFile.exists()) {
        logoImage = await logoFile.readAsBytes();
      }
    }

    if (_selectedProgram!.signaturePath != null) {
      final sigFile = File(_selectedProgram!.signaturePath!);
      if (await sigFile.exists()) {
        signatureImage = await sigFile.readAsBytes();
      }
    }

    if (_selectedProgram!.signaturePath2 != null) {
      final sigFile2 = File(_selectedProgram!.signaturePath2!);
      if (await sigFile2.exists()) {
        signatureImage2 = await sigFile2.readAsBytes();
      }
    }

    if (_selectedProgram!.signaturePath3 != null) {
      final sigFile3 = File(_selectedProgram!.signaturePath3!);
      if (await sigFile3.exists()) {
        signatureImage3 = await sigFile3.readAsBytes();
      }
    }

    List<Map<String, dynamic>> certificateDataList = [];

    for (final participant in participants) {
      final existingCert = await _certificateRepo.getByParticipantId(participant.id!);
      
      Certificate certificate;
      if (existingCert != null) {
        certificate = existingCert;
      } else {
        final certNumber = await _certificateRepo.generateCertificateNumber(
          _selectedProgram!.programCode,
          _selectedProgram!.programYear,
        );
        final uniqueCode = _uuid.v4();

        certificate = Certificate(
          participantId: participant.id!,
          uniqueCode: uniqueCode,
          certificateNumber: certNumber,
          generatedAt: DateTime.now(),
        );

        final qrData = _qrService.generateQrData(
          certificate: certificate,
          participant: participant,
          program: _selectedProgram!,
          secretKey: secretKey,
        );

        final certToSave = certificate.copyWith(qrData: qrData);
        await _certificateRepo.insert(certToSave);
        _totalCertificates = await _certificateRepo.getCount();
      }

      final qrData = _qrService.generateQrData(
        certificate: certificate,
        participant: participant,
        program: _selectedProgram!,
        secretKey: secretKey,
        verificationUrl: verificationUrl,
      );

      final qrImage = await _qrService.generateQrImage(qrData);

      certificateDataList.add({
        'certificate': certificate,
        'participant': participant,
        'qrImage': qrImage,
      });
    }

    final combinedPdf = await _pdfService.generateCombinedCertificates(
      certificateDataList: certificateDataList,
      program: _selectedProgram!,
      logoImage: logoImage,
      signatureImage: signatureImage,
      signatureImage2: signatureImage2,
      signatureImage3: signatureImage3,
    );

    // Auto-update CSV for online verification
    await _autoCsvService.updateCsvFile();

    await loadParticipants(_selectedProgram!.id!);
    notifyListeners();
    
    return combinedPdf;
  }
}
