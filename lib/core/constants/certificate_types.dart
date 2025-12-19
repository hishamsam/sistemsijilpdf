enum CertificateType {
  penyertaan('Penyertaan', 'Certificate of Participation'),
  penghargaan('Penghargaan', 'Certificate of Appreciation'),
  pencapaian('Pencapaian', 'Certificate of Achievement'),
  kehadiran('Kehadiran', 'Certificate of Attendance');

  final String malay;
  final String english;

  const CertificateType(this.malay, this.english);

  static CertificateType fromString(String value) {
    return CertificateType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CertificateType.penyertaan,
    );
  }
}

enum TemplateStyle {
  moden('Moden'),
  klasik('Klasik'),
  formal('Formal'),
  kreatif('Kreatif');

  final String label;

  const TemplateStyle(this.label);

  static TemplateStyle fromString(String value) {
    return TemplateStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TemplateStyle.moden,
    );
  }
}
