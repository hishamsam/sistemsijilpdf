import '../database/database_helper.dart';
import '../models/program.dart';

class ProgramRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Program>> getAll() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT p.*, 
             (SELECT COUNT(*) FROM participants WHERE program_id = p.id) as participant_count,
             (SELECT COUNT(*) FROM certificates c 
              INNER JOIN participants pt ON c.participant_id = pt.id 
              WHERE pt.program_id = p.id) as certificate_count
      FROM programs p
      ORDER BY p.created_at DESC
    ''');
    return result.map((map) => Program.fromMap(map)).toList();
  }

  Future<Program?> getById(int id) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT p.*, 
             (SELECT COUNT(*) FROM participants WHERE program_id = p.id) as participant_count,
             (SELECT COUNT(*) FROM certificates c 
              INNER JOIN participants pt ON c.participant_id = pt.id 
              WHERE pt.program_id = p.id) as certificate_count
      FROM programs p
      WHERE p.id = ?
    ''', [id]);
    if (result.isEmpty) return null;
    return Program.fromMap(result.first);
  }

  Future<Program?> getByCode(String code) async {
    final db = await _db.database;
    final result = await db.query(
      'programs',
      where: 'program_code = ?',
      whereArgs: [code],
    );
    if (result.isEmpty) return null;
    return Program.fromMap(result.first);
  }

  Future<int> insert(Program program) async {
    final db = await _db.database;
    return await db.insert('programs', program.toMap()..remove('id'));
  }

  Future<int> update(Program program) async {
    final db = await _db.database;
    return await db.update(
      'programs',
      program.toMap()..['updated_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [program.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'programs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM programs');
    return result.first['count'] as int;
  }

  Future<List<Program>> search(String query) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT p.*, 
             (SELECT COUNT(*) FROM participants WHERE program_id = p.id) as participant_count,
             (SELECT COUNT(*) FROM certificates c 
              INNER JOIN participants pt ON c.participant_id = pt.id 
              WHERE pt.program_id = p.id) as certificate_count
      FROM programs p
      WHERE p.program_name LIKE ? OR p.program_code LIKE ?
      ORDER BY p.created_at DESC
    ''', ['%$query%', '%$query%']);
    return result.map((map) => Program.fromMap(map)).toList();
  }

  Future<bool> codeExists(String code, {int? excludeId}) async {
    final db = await _db.database;
    String query = 'SELECT COUNT(*) as count FROM programs WHERE program_code = ?';
    List<dynamic> args = [code];
    
    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }
    
    final result = await db.rawQuery(query, args);
    return (result.first['count'] as int) > 0;
  }
}
