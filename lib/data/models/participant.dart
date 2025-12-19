class Participant {
  final int? id;
  final int programId;
  final String fullName;
  final String icNumber;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool hasCertificate;

  Participant({
    this.id,
    required this.programId,
    required this.fullName,
    required this.icNumber,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.hasCertificate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'program_id': programId,
      'full_name': fullName,
      'ic_number': icNumber,
      'email': email,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] as int?,
      programId: map['program_id'] as int,
      fullName: map['full_name'] as String,
      icNumber: map['ic_number'] as String,
      email: map['email'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      hasCertificate: (map['has_certificate'] as int? ?? 0) == 1,
    );
  }

  Participant copyWith({
    int? id,
    int? programId,
    String? fullName,
    String? icNumber,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasCertificate,
  }) {
    return Participant(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      fullName: fullName ?? this.fullName,
      icNumber: icNumber ?? this.icNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasCertificate: hasCertificate ?? this.hasCertificate,
    );
  }
}
