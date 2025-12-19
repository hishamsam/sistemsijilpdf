import '../database/database_helper.dart';
import '../models/certificate.dart';

class CertificateRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Certificate>> getAll() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      ORDER BY c.created_at DESC
    ''');
    return result.map((map) => Certificate.fromMap(map)).toList();
  }

  Future<List<Certificate>> getByProgramId(int programId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE pr.id = ?
      ORDER BY c.created_at DESC
    ''', [programId]);
    return result.map((map) => Certificate.fromMap(map)).toList();
  }

  Future<Certificate?> getById(int id) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE c.id = ?
    ''', [id]);
    if (result.isEmpty) return null;
    return Certificate.fromMap(result.first);
  }

  Future<Certificate?> getByParticipantId(int participantId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE c.participant_id = ?
    ''', [participantId]);
    if (result.isEmpty) return null;
    return Certificate.fromMap(result.first);
  }

  Future<Certificate?> getByUniqueCode(String code) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE c.unique_code = ?
    ''', [code]);
    if (result.isEmpty) return null;
    return Certificate.fromMap(result.first);
  }

  Future<Certificate?> getByCertificateNumber(String certNumber) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE c.certificate_number = ?
    ''', [certNumber]);
    if (result.isEmpty) return null;
    return Certificate.fromMap(result.first);
  }

  Future<int> insert(Certificate certificate) async {
    final db = await _db.database;
    return await db.insert('certificates', certificate.toMap()..remove('id'));
  }

  Future<int> update(Certificate certificate) async {
    final db = await _db.database;
    return await db.update(
      'certificates',
      certificate.toMap()..['updated_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [certificate.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'certificates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByParticipantId(int participantId) async {
    final db = await _db.database;
    return await db.delete(
      'certificates',
      where: 'participant_id = ?',
      whereArgs: [participantId],
    );
  }

  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM certificates');
    return result.first['count'] as int;
  }

  Future<int> getCountByProgram(int programId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      WHERE p.program_id = ?
    ''', [programId]);
    return result.first['count'] as int;
  }

  Future<int> updateVerificationCount(String uniqueCode) async {
    final db = await _db.database;
    return await db.rawUpdate('''
      UPDATE certificates 
      SET verification_count = verification_count + 1,
          is_verified = 1,
          last_verified_at = ?,
          updated_at = ?
      WHERE unique_code = ?
    ''', [
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String(),
      uniqueCode,
    ]);
  }

  Future<List<Certificate>> search(String query) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE p.full_name LIKE ? 
         OR c.certificate_number LIKE ? 
         OR c.unique_code LIKE ?
      ORDER BY c.created_at DESC
    ''', ['%$query%', '%$query%', '%$query%']);
    return result.map((map) => Certificate.fromMap(map)).toList();
  }

  Future<String> generateCertificateNumber(String programCode, int year) async {
    final db = await _db.database;
    final prefix = 'CERT-$programCode-$year-';
    
    final result = await db.rawQuery('''
      SELECT certificate_number FROM certificates 
      WHERE certificate_number LIKE ?
      ORDER BY certificate_number DESC
      LIMIT 1
    ''', ['$prefix%']);
    
    int nextNumber = 1;
    if (result.isNotEmpty) {
      final lastNumber = result.first['certificate_number'] as String;
      final parts = lastNumber.split('-');
      if (parts.length >= 4) {
        nextNumber = int.tryParse(parts.last) ?? 0;
        nextNumber++;
      }
    }
    
    return '$prefix${nextNumber.toString().padLeft(4, '0')}';
  }

  Future<int> revokeCertificate(int id, String reason) async {
    final db = await _db.database;
    return await db.update(
      'certificates',
      {
        'is_revoked': 1,
        'revoked_at': DateTime.now().toIso8601String(),
        'revocation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> unrevokeCertificate(int id) async {
    final db = await _db.database;
    return await db.update(
      'certificates',
      {
        'is_revoked': 0,
        'revoked_at': null,
        'revocation_reason': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Certificate>> getRevokedCertificates() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT c.*, p.full_name as participant_name, pr.program_name
      FROM certificates c
      INNER JOIN participants p ON c.participant_id = p.id
      INNER JOIN programs pr ON p.program_id = pr.id
      WHERE c.is_revoked = 1
      ORDER BY c.revoked_at DESC
    ''');
    return result.map((map) => Certificate.fromMap(map)).toList();
  }

  Future<int> bulkRegenerate(List<int> certificateIds) async {
    final db = await _db.database;
    int count = 0;
    for (final id in certificateIds) {
      await db.update(
        'certificates',
        {
          'pdf_path': null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      count++;
    }
    return count;
  }

  Future<int> clearPdfPathsByProgramId(int programId) async {
    final db = await _db.database;
    return await db.rawUpdate('''
      UPDATE certificates 
      SET pdf_path = NULL, updated_at = ?
      WHERE participant_id IN (
        SELECT id FROM participants WHERE program_id = ?
      )
    ''', [DateTime.now().toIso8601String(), programId]);
  }
}
