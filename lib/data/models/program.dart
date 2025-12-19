class Program {
  final int? id;
  final String programName;
  final String programCode;
  final int programYear;
  final String certificateType;
  final String templateStyle;
  final String language;
  final String? description;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? organizer;
  final String? organizerTagline;
  final String? logoPath;
  final String? signaturePath;
  final String? signatoryName;
  final String? signatoryTitle;
  final String? signaturePath2;
  final String? signatoryName2;
  final String? signatoryTitle2;
  final String? signaturePath3;
  final String? signatoryName3;
  final String? signatoryTitle3;
  final String? watermarkText;
  final double watermarkOpacity;
  final String qrPosition;
  final bool showIcNumber;
  final int? customTemplateId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  int participantCount;
  int certificateCount;

  Program({
    this.id,
    required this.programName,
    required this.programCode,
    required this.programYear,
    this.certificateType = 'penyertaan',
    this.templateStyle = 'moden',
    this.language = 'bilingual',
    this.description,
    required this.issueDate,
    this.expiryDate,
    this.organizer,
    this.organizerTagline,
    this.logoPath,
    this.signaturePath,
    this.signatoryName,
    this.signatoryTitle,
    this.signaturePath2,
    this.signatoryName2,
    this.signatoryTitle2,
    this.signaturePath3,
    this.signatoryName3,
    this.signatoryTitle3,
    this.watermarkText,
    this.watermarkOpacity = 0.1,
    this.qrPosition = 'bottom-right',
    this.showIcNumber = false,
    this.customTemplateId,
    this.createdAt,
    this.updatedAt,
    this.participantCount = 0,
    this.certificateCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'program_name': programName,
      'program_code': programCode,
      'program_year': programYear,
      'certificate_type': certificateType,
      'template_style': templateStyle,
      'language': language,
      'description': description,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'organizer': organizer,
      'organizer_tagline': organizerTagline,
      'logo_path': logoPath,
      'signature_path': signaturePath,
      'signatory_name': signatoryName,
      'signatory_title': signatoryTitle,
      'signature_path_2': signaturePath2,
      'signatory_name_2': signatoryName2,
      'signatory_title_2': signatoryTitle2,
      'signature_path_3': signaturePath3,
      'signatory_name_3': signatoryName3,
      'signatory_title_3': signatoryTitle3,
      'watermark_text': watermarkText,
      'watermark_opacity': watermarkOpacity,
      'qr_position': qrPosition,
      'show_ic_number': showIcNumber ? 1 : 0,
      'custom_template_id': customTemplateId,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['id'] as int?,
      programName: map['program_name'] as String,
      programCode: map['program_code'] as String,
      programYear: map['program_year'] as int,
      certificateType: map['certificate_type'] as String? ?? 'penyertaan',
      templateStyle: map['template_style'] as String? ?? 'moden',
      language: map['language'] as String? ?? 'bilingual',
      description: map['description'] as String?,
      issueDate: DateTime.parse(map['issue_date'] as String),
      expiryDate: map['expiry_date'] != null ? DateTime.parse(map['expiry_date'] as String) : null,
      organizer: map['organizer'] as String?,
      organizerTagline: map['organizer_tagline'] as String?,
      logoPath: map['logo_path'] as String?,
      signaturePath: map['signature_path'] as String?,
      signatoryName: map['signatory_name'] as String?,
      signatoryTitle: map['signatory_title'] as String?,
      signaturePath2: map['signature_path_2'] as String?,
      signatoryName2: map['signatory_name_2'] as String?,
      signatoryTitle2: map['signatory_title_2'] as String?,
      signaturePath3: map['signature_path_3'] as String?,
      signatoryName3: map['signatory_name_3'] as String?,
      signatoryTitle3: map['signatory_title_3'] as String?,
      watermarkText: map['watermark_text'] as String?,
      watermarkOpacity: (map['watermark_opacity'] as num?)?.toDouble() ?? 0.1,
      qrPosition: map['qr_position'] as String? ?? 'bottom-right',
      showIcNumber: (map['show_ic_number'] as int?) == 1,
      customTemplateId: map['custom_template_id'] as int?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      participantCount: map['participant_count'] as int? ?? 0,
      certificateCount: map['certificate_count'] as int? ?? 0,
    );
  }

  Program copyWith({
    int? id,
    String? programName,
    String? programCode,
    int? programYear,
    String? certificateType,
    String? templateStyle,
    String? language,
    String? description,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? organizer,
    String? organizerTagline,
    String? logoPath,
    String? signaturePath,
    String? signatoryName,
    String? signatoryTitle,
    String? signaturePath2,
    String? signatoryName2,
    String? signatoryTitle2,
    String? signaturePath3,
    String? signatoryName3,
    String? signatoryTitle3,
    String? watermarkText,
    double? watermarkOpacity,
    String? qrPosition,
    bool? showIcNumber,
    int? customTemplateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? participantCount,
    int? certificateCount,
  }) {
    return Program(
      id: id ?? this.id,
      programName: programName ?? this.programName,
      programCode: programCode ?? this.programCode,
      programYear: programYear ?? this.programYear,
      certificateType: certificateType ?? this.certificateType,
      templateStyle: templateStyle ?? this.templateStyle,
      language: language ?? this.language,
      description: description ?? this.description,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      organizer: organizer ?? this.organizer,
      organizerTagline: organizerTagline ?? this.organizerTagline,
      logoPath: logoPath ?? this.logoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      signatoryName: signatoryName ?? this.signatoryName,
      signatoryTitle: signatoryTitle ?? this.signatoryTitle,
      signaturePath2: signaturePath2 ?? this.signaturePath2,
      signatoryName2: signatoryName2 ?? this.signatoryName2,
      signatoryTitle2: signatoryTitle2 ?? this.signatoryTitle2,
      signaturePath3: signaturePath3 ?? this.signaturePath3,
      signatoryName3: signatoryName3 ?? this.signatoryName3,
      signatoryTitle3: signatoryTitle3 ?? this.signatoryTitle3,
      watermarkText: watermarkText ?? this.watermarkText,
      watermarkOpacity: watermarkOpacity ?? this.watermarkOpacity,
      qrPosition: qrPosition ?? this.qrPosition,
      showIcNumber: showIcNumber ?? this.showIcNumber,
      customTemplateId: customTemplateId ?? this.customTemplateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participantCount: participantCount ?? this.participantCount,
      certificateCount: certificateCount ?? this.certificateCount,
    );
  }
}
