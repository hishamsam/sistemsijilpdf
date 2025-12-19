import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_sijil/core/localization/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('should have navigation strings', () {
      expect(AppStrings.getByLang('dashboard', 'ms'), isNotNull);
      expect(AppStrings.getByLang('program', 'ms'), isNotNull);
      expect(AppStrings.getByLang('certificate_verification', 'ms'), isNotNull);
      expect(AppStrings.getByLang('settings', 'ms'), isNotNull);
    });

    test('should return correct ms translation for dashboard', () {
      expect(AppStrings.getByLang('dashboard', 'ms'), 'Dashboard');
      expect(AppStrings.getByLang('dashboard', 'en'), 'Dashboard');
    });

    test('should return correct translations for program', () {
      expect(AppStrings.getByLang('program', 'ms'), 'Program');
      expect(AppStrings.getByLang('program', 'en'), 'Programs');
    });

    test('should return correct translations for settings', () {
      expect(AppStrings.getByLang('settings', 'ms'), 'Tetapan');
      expect(AppStrings.getByLang('settings', 'en'), 'Settings');
    });

    test('should have login screen translations', () {
      expect(AppStrings.getByLang('enter_password', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('login', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('wrong_password', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('welcome_back', 'ms'), isNotEmpty);
    });

    test('should have factory reset translations', () {
      expect(AppStrings.getByLang('factory_reset', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('factory_reset_desc', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('factory_reset_confirm', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('factory_reset_warning', 'ms'), isNotEmpty);
    });

    test('should have form field translations', () {
      expect(AppStrings.getByLang('program_name', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('program_code', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('certificate_type', 'ms'), isNotEmpty);
    });

    test('should have action button translations', () {
      expect(AppStrings.getByLang('save', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('cancel', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('delete', 'ms'), isNotEmpty);
      expect(AppStrings.getByLang('search', 'ms'), isNotEmpty);
    });

    test('should return key if translation not found', () {
      final result = AppStrings.getByLang('non_existent_key_xyz', 'ms');
      expect(result, 'non_existent_key_xyz');
    });

    test('should return ms translation as fallback for unknown language', () {
      final resultMs = AppStrings.getByLang('dashboard', 'ms');
      final resultUnknown = AppStrings.getByLang('dashboard', 'fr');
      expect(resultUnknown, resultMs);
    });
  });
}
