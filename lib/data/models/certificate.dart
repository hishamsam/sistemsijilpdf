class Certificate {
  final int? id;
  final int participantId;
  final String uniqueCode;
  final String certificateNumber;
  final String? pdfPath;
  final String? qrData;
  final String? verificationHash;
  final bool isVerified;
  final int verificationCount;
  final DateTime? lastVerifiedAt;
  final DateTime? generatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isRevoked;
  final DateTime? revokedAt;
  final String? revocationReason;

  String? participantName;
  String? programName;

  Certificate({
    this.id,
    required this.participantId,
    required this.uniqueCode,
    required this.certificateNumber,
    this.pdfPath,
    this.qrData,
    this.verificationHash,
    this.isVerified = false,
    this.verificationCount = 0,
    this.lastVerifiedAt,
    this.generatedAt,
    this.createdAt,
    this.updatedAt,
    this.isRevoked = false,
    this.revokedAt,
    this.revocationReason,
    this.participantName,
    this.programName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_id': participantId,
      'unique_code': uniqueCode,
      'certificate_number': certificateNumber,
      'pdf_path': pdfPath,
      'qr_data': qrData,
      'verification_hash': verificationHash,
      'is_verified': isVerified ? 1 : 0,
      'verification_count': verificationCount,
      'last_verified_at': lastVerifiedAt?.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'is_revoked': isRevoked ? 1 : 0,
      'revoked_at': revokedAt?.toIso8601String(),
      'revocation_reason': revocationReason,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'] as int?,
      participantId: map['participant_id'] as int,
      uniqueCode: map['unique_code'] as String,
      certificateNumber: map['certificate_number'] as String,
      pdfPath: map['pdf_path'] as String?,
      qrData: map['qr_data'] as String?,
      verificationHash: map['verification_hash'] as String?,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      verificationCount: map['verification_count'] as int? ?? 0,
      lastVerifiedAt: map['last_verified_at'] != null
          ? DateTime.parse(map['last_verified_at'] as String)
          : null,
      generatedAt: map['generated_at'] != null
          ? DateTime.parse(map['generated_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isRevoked: (map['is_revoked'] as int? ?? 0) == 1,
      revokedAt: map['revoked_at'] != null
          ? DateTime.parse(map['revoked_at'] as String)
          : null,
      revocationReason: map['revocation_reason'] as String?,
      participantName: map['participant_name'] as String?,
      programName: map['program_name'] as String?,
    );
  }

  Certificate copyWith({
    int? id,
    int? participantId,
    String? uniqueCode,
    String? certificateNumber,
    String? pdfPath,
    String? qrData,
    String? verificationHash,
    bool? isVerified,
    int? verificationCount,
    DateTime? lastVerifiedAt,
    DateTime? generatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRevoked,
    DateTime? revokedAt,
    String? revocationReason,
    String? participantName,
    String? programName,
  }) {
    return Certificate(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      pdfPath: pdfPath ?? this.pdfPath,
      qrData: qrData ?? this.qrData,
      verificationHash: verificationHash ?? this.verificationHash,
      isVerified: isVerified ?? this.isVerified,
      verificationCount: verificationCount ?? this.verificationCount,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      generatedAt: generatedAt ?? this.generatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt ?? this.revokedAt,
      revocationReason: revocationReason ?? this.revocationReason,
      participantName: participantName ?? this.participantName,
      programName: programName ?? this.programName,
    );
  }
}
