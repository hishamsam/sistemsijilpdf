import 'package:flutter/material.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/program_repository.dart';
import '../../../data/repositories/participant_repository.dart';
import '../../../data/repositories/certificate_repository.dart';
import '../../../data/database/database_helper.dart';
import '../../../core/utils/crypto_utils.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _settingsRepo = SettingsRepository();
  final ProgramRepository _programRepo = ProgramRepository();
  final ParticipantRepository _participantRepo = ParticipantRepository();
  final CertificateRepository _certificateRepo = CertificateRepository();

  ThemeMode _themeMode = ThemeMode.light;
  bool _hasPassword = false;
  bool _isAuthenticated = false;
  String _language = 'ms'; // default: Bahasa Melayu

  ThemeMode get themeMode => _themeMode;
  bool get hasPassword => _hasPassword;
  bool get isAuthenticated => _isAuthenticated;
  String get language => _language;

  Future<void> initialize() async {
    final theme = await _settingsRepo.getTheme();
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _hasPassword = await _settingsRepo.hasPassword();
    _language = await _settingsRepo.getLanguage();
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _settingsRepo.setLanguage(lang);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settingsRepo.setTheme(mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setPassword(String password) async {
    final hash = CryptoUtils.hashPassword(password);
    await _settingsRepo.setPasswordHash(hash);
    _hasPassword = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> verifyPassword(String password) async {
    final storedHash = await _settingsRepo.getPasswordHash();
    if (storedHash == null) return true;

    final isValid = CryptoUtils.verifyPassword(password, storedHash);
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  Future<void> removePassword() async {
    await _settingsRepo.delete('app_password_hash');
    _hasPassword = false;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<Map<String, int>> getStatistics() async {
    final programCount = await _programRepo.getCount();
    final participantCount = await _participantRepo.getCount();
    final certificateCount = await _certificateRepo.getCount();

    return {
      'programs': programCount,
      'participants': participantCount,
      'certificates': certificateCount,
    };
  }

  Future<String> getSecretKey() async {
    return await _settingsRepo.getSecretKey();
  }

  Future<void> setSecretKey(String key) async {
    await _settingsRepo.setSecretKey(key);
  }

  Future<void> factoryReset() async {
    final db = DatabaseHelper.instance;
    await db.factoryReset();
    
    // Reset state
    _themeMode = ThemeMode.light;
    _hasPassword = false;
    _isAuthenticated = false;
    _language = 'ms';
    
    notifyListeners();
  }
}
