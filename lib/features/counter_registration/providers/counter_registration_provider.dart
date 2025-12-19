import 'package:flutter/material.dart';
import '../../../data/models/program.dart';
import '../../../data/models/participant.dart';
import '../../../data/repositories/program_repository.dart';
import '../../../data/repositories/participant_repository.dart';

class CounterRegistrationProvider extends ChangeNotifier {
  final ProgramRepository _programRepo = ProgramRepository();
  final ParticipantRepository _participantRepo = ParticipantRepository();

  List<Program> _programs = [];
  Program? _selectedProgram;
  List<Participant> _registeredParticipants = [];
  bool _isLoading = false;
  int _todayRegistrationCount = 0;

  List<Program> get programs => _programs;
  Program? get selectedProgram => _selectedProgram;
  List<Participant> get registeredParticipants => _registeredParticipants;
  bool get isLoading => _isLoading;
  int get todayRegistrationCount => _todayRegistrationCount;

  Future<void> loadPrograms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _programs = await _programRepo.getAll();
    } catch (e) {
      // Handle silently
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectProgram(Program? program) async {
    _selectedProgram = program;
    
    if (program != null) {
      await _loadTodayRegistrations();
    } else {
      _registeredParticipants = [];
      _todayRegistrationCount = 0;
    }
    
    notifyListeners();
  }

  Future<void> _loadTodayRegistrations() async {
    if (_selectedProgram == null) return;
    
    try {
      final allParticipants = await _participantRepo.getByProgramId(_selectedProgram!.id!);
      final today = DateTime.now();
      
      _registeredParticipants = allParticipants.where((p) {
        if (p.createdAt == null) return false;
        return p.createdAt!.year == today.year &&
               p.createdAt!.month == today.month &&
               p.createdAt!.day == today.day;
      }).toList();
      
      _todayRegistrationCount = _registeredParticipants.length;
    } catch (e) {
      // Handle silently
    }
  }

  Future<Map<String, dynamic>> registerParticipant({
    required String fullName,
    required String icNumber,
    String? email,
  }) async {
    if (_selectedProgram == null) {
      return {'success': false, 'errorKey': 'please_select_program_first'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final exists = await _participantRepo.icExistsInProgram(
        icNumber, 
        _selectedProgram!.id!,
      );
      
      if (exists) {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'errorKey': 'participant_already_registered'};
      }

      final formattedName = _toTitleCase(fullName);
      
      final participant = Participant(
        programId: _selectedProgram!.id!,
        fullName: formattedName,
        icNumber: icNumber,
        email: email,
        createdAt: DateTime.now(),
      );

      await _participantRepo.insert(participant);
      
      await _loadTodayRegistrations();
      
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'name': formattedName};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'errorKey': 'registration_error', 'details': e.toString()};
    }
  }

  Future<Participant?> checkExistingParticipant(String icNumber) async {
    if (_selectedProgram == null) return null;
    
    try {
      return await _participantRepo.getByIcAndProgram(
        icNumber, 
        _selectedProgram!.id!,
      );
    } catch (e) {
      return null;
    }
  }

  void reset() {
    _selectedProgram = null;
    _registeredParticipants = [];
    _todayRegistrationCount = 0;
    notifyListeners();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
