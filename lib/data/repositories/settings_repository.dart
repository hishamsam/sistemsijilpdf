import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class SettingsRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<String?> get(String key) async {
    final db = await _db.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> set(String key, String value) async {
    final db = await _db.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String key) async {
    final db = await _db.database;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<Map<String, String>> getAll() async {
    final db = await _db.database;
    final result = await db.query('settings');
    return Map.fromEntries(
      result.map((row) => MapEntry(row['key'] as String, row['value'] as String)),
    );
  }

  Future<String> getSecretKey() async {
    return await get('secret_key') ?? 'sistem-sijil-secret-key-2024';
  }

  Future<void> setSecretKey(String key) async {
    await set('secret_key', key);
  }

  Future<String> getTheme() async {
    return await get('theme') ?? 'light';
  }

  Future<void> setTheme(String theme) async {
    await set('theme', theme);
  }

  Future<String?> getPasswordHash() async {
    return await get('app_password_hash');
  }

  Future<void> setPasswordHash(String hash) async {
    await set('app_password_hash', hash);
  }

  Future<bool> hasPassword() async {
    final hash = await getPasswordHash();
    return hash != null && hash.isNotEmpty;
  }

  // Verification URL for QR codes
  Future<String?> getVerificationUrl() async {
    return await get('verification_url');
  }

  Future<void> setVerificationUrl(String url) async {
    await set('verification_url', url);
  }

  // Language setting
  Future<String> getLanguage() async {
    return await get('language') ?? 'ms'; // default: Bahasa Melayu
  }

  Future<void> setLanguage(String lang) async {
    await set('language', lang);
  }
}
