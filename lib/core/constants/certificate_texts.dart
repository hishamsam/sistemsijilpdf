/// Certificate text translations for multi-language support
class CertificateTexts {
  final String language;

  CertificateTexts(this.language);

  // Certificate Titles
  String getCertificateTitle(String type) {
    switch (language) {
      case 'malay':
        return _getTitleMalay(type);
      case 'english':
        return _getTitleEnglish(type);
      default: // bilingual
        return _getTitleMalay(type);
    }
  }

  String? getCertificateTitleSecondary(String type) {
    if (language == 'bilingual') {
      return _getTitleEnglish(type);
    }
    return null;
  }

  static String _getTitleMalay(String type) {
    switch (type) {
      case 'penghargaan':
        return 'SIJIL PENGHARGAAN';
      case 'pencapaian':
        return 'SIJIL PENCAPAIAN';
      case 'kehadiran':
        return 'SIJIL KEHADIRAN';
      default:
        return 'SIJIL PENYERTAAN';
    }
  }

  static String _getTitleEnglish(String type) {
    switch (type) {
      case 'penghargaan':
        return 'Certificate of Appreciation';
      case 'pencapaian':
        return 'Certificate of Achievement';
      case 'kehadiran':
        return 'Certificate of Attendance';
      default:
        return 'Certificate of Participation';
    }
  }

  // Certification text
  String get certificationText {
    switch (language) {
      case 'malay':
        return 'Dengan ini mengesahkan bahawa';
      case 'english':
        return 'This is to certify that';
      default:
        return 'Dengan ini mengesahkan bahawa';
    }
  }

  String? get certificationTextSecondary {
    if (language == 'bilingual') {
      return 'This is to certify that';
    }
    return null;
  }

  // Participation text
  String getParticipationText(String type) {
    switch (language) {
      case 'malay':
        return _getParticipationMalay(type);
      case 'english':
        return _getParticipationEnglish(type);
      default:
        return _getParticipationMalay(type);
    }
  }

  String? getParticipationTextSecondary(String type) {
    if (language == 'bilingual') {
      return _getParticipationEnglish(type);
    }
    return null;
  }

  static String _getParticipationMalay(String type) {
    switch (type) {
      case 'penghargaan':
        return 'Atas sumbangan dan dedikasi dalam';
      case 'pencapaian':
        return 'Telah berjaya mencapai kecemerlangan dalam';
      case 'kehadiran':
        return 'Telah menghadiri';
      default:
        return 'Telah berjaya menyertai';
    }
  }

  static String _getParticipationEnglish(String type) {
    switch (type) {
      case 'penghargaan':
        return 'For contribution and dedication in';
      case 'pencapaian':
        return 'Has successfully achieved excellence in';
      case 'kehadiran':
        return 'Has attended';
      default:
        return 'Has successfully participated in';
    }
  }

  // Date label
  String get dateLabel {
    switch (language) {
      case 'malay':
        return 'Tarikh';
      case 'english':
        return 'Date';
      default:
        return 'Tarikh';
    }
  }

  String? get dateLabelSecondary {
    if (language == 'bilingual') {
      return 'Date';
    }
    return null;
  }

  // Certificate number label
  String get certificateNumberLabel {
    switch (language) {
      case 'malay':
        return 'No. Sijil';
      case 'english':
        return 'Certificate No.';
      default:
        return 'No. Sijil';
    }
  }

  String? get certificateNumberLabelSecondary {
    if (language == 'bilingual') {
      return 'Certificate No.';
    }
    return null;
  }

  // Signatory title
  String get programDirector {
    switch (language) {
      case 'malay':
        return 'Pengarah Program';
      case 'english':
        return 'Programme Director';
      default:
        return 'Pengarah Program';
    }
  }

  String? get programDirectorSecondary {
    if (language == 'bilingual') {
      return 'Programme Director';
    }
    return null;
  }

  // QR scan text
  String get scanToVerify {
    switch (language) {
      case 'malay':
        return 'Imbas untuk pengesahan';
      case 'english':
        return 'Scan to verify';
      default:
        return 'Imbas untuk pengesahan';
    }
  }

  String? get scanToVerifySecondary {
    if (language == 'bilingual') {
      return 'Scan to verify';
    }
    return null;
  }
}
