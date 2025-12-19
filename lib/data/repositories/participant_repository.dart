import '../database/database_helper.dart';
import '../models/participant.dart';

class ParticipantRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Participant>> getByProgramId(int programId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT p.*, 
             CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END as has_certificate
      FROM participants p
      LEFT JOIN certificates c ON c.participant_id = p.id
      WHERE p.program_id = ?
      ORDER BY p.full_name ASC
    ''', [programId]);
    return result.map((map) => Participant.fromMap(map)).toList();
  }

  Future<Participant?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'participants',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Participant.fromMap(result.first);
  }

  Future<Participant?> getByIcAndProgram(String icNumber, int programId) async {
    final db = await _db.database;
    final result = await db.query(
      'participants',
      where: 'ic_number = ? AND program_id = ?',
      whereArgs: [icNumber, programId],
    );
    if (result.isEmpty) return null;
    return Participant.fromMap(result.first);
  }

  Future<int> insert(Participant participant) async {
    final db = await _db.database;
    return await db.insert('participants', participant.toMap()..remove('id'));
  }

  Future<void> insertBatch(List<Participant> participants) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final participant in participants) {
      batch.insert('participants', participant.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  Future<int> update(Participant participant) async {
    final db = await _db.database;
    return await db.update(
      'participants',
      participant.toMap()..['updated_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [participant.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'participants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByProgramId(int programId) async {
    final db = await _db.database;
    return await db.delete(
      'participants',
      where: 'program_id = ?',
      whereArgs: [programId],
    );
  }

  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM participants');
    return result.first['count'] as int;
  }

  Future<int> getCountByProgram(int programId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM participants WHERE program_id = ?',
      [programId],
    );
    return result.first['count'] as int;
  }

  Future<List<Participant>> search(String query, {int? programId}) async {
    final db = await _db.database;
    String sql = '''
      SELECT p.*, 
             CASE WHEN c.id IS NOT NULL THEN 1 ELSE 0 END as has_certificate
      FROM participants p
      LEFT JOIN certificates c ON c.participant_id = p.id
      WHERE (p.full_name LIKE ? OR p.ic_number LIKE ?)
    ''';
    List<dynamic> args = ['%$query%', '%$query%'];
    
    if (programId != null) {
      sql += ' AND p.program_id = ?';
      args.add(programId);
    }
    
    sql += ' ORDER BY p.full_name ASC';
    
    final result = await db.rawQuery(sql, args);
    return result.map((map) => Participant.fromMap(map)).toList();
  }

  Future<bool> icExistsInProgram(String icNumber, int programId, {int? excludeId}) async {
    final db = await _db.database;
    String query = 'SELECT COUNT(*) as count FROM participants WHERE ic_number = ? AND program_id = ?';
    List<dynamic> args = [icNumber, programId];
    
    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }
    
    final result = await db.rawQuery(query, args);
    return (result.first['count'] as int) > 0;
  }
}
