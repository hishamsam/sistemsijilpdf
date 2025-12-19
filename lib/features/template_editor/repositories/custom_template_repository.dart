import '../../../data/database/database_helper.dart';
import '../models/custom_template.dart';

class CustomTemplateRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> insert(CustomTemplate template) async {
    final db = await _db.database;
    final map = template.toMap();
    map['created_at'] = DateTime.now().toIso8601String();
    map['updated_at'] = DateTime.now().toIso8601String();
    map.remove('id');
    return await db.insert('custom_templates', map);
  }

  Future<int> update(CustomTemplate template) async {
    final db = await _db.database;
    final map = template.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'custom_templates',
      map,
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('custom_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<CustomTemplate?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('custom_templates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CustomTemplate.fromMap(maps.first);
  }

  Future<List<CustomTemplate>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('custom_templates', orderBy: 'updated_at DESC');
    return maps.map((m) => CustomTemplate.fromMap(m)).toList();
  }

  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM custom_templates');
    return result.first['count'] as int;
  }
}
