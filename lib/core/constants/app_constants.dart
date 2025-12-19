class AppConstants {
  static const String appName = 'Sistem Sijil';
  static const String appVersion = '1.5.0';
  static const String databaseName = 'sistem_sijil.db';
  static const int databaseVersion = 7;

  static const String defaultSecretKey = 'sistem-sijil-secret-key-2024';

  static const List<String> certificateTypes = [
    'penyertaan',
    'penghargaan',
    'pencapaian',
    'kehadiran',
  ];

  static const List<String> templateStyles = [
    'moden',
    'klasik',
    'formal',
    'kreatif',
  ];

  static const List<String> languages = [
    'bilingual',
    'malay',
    'english',
  ];

  static const Map<String, String> languageLabels = {
    'bilingual': 'Dwibahasa (BM & EN)',
    'malay': 'Bahasa Melayu',
    'english': 'English',
  };

  static const List<String> qrPositions = [
    'bottom-right',
    'bottom-left',
    'top-right',
    'top-left',
    'bottom-center',
  ];

  static const Map<String, String> qrPositionLabels = {
    'bottom-right': 'Bawah Kanan',
    'bottom-left': 'Bawah Kiri',
    'top-right': 'Atas Kanan',
    'top-left': 'Atas Kiri',
    'bottom-center': 'Bawah Tengah',
  };
}
