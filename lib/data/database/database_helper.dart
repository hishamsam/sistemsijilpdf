import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'SistemSijil', AppConstants.databaseName);
    
    final dir = Directory(p.dirname(path));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE programs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        program_name TEXT NOT NULL,
        program_code TEXT UNIQUE NOT NULL,
        program_year INTEGER NOT NULL,
        certificate_type TEXT DEFAULT 'penyertaan',
        template_style TEXT DEFAULT 'moden',
        language TEXT DEFAULT 'bilingual',
        description TEXT,
        issue_date TEXT NOT NULL,
        organizer TEXT,
        organizer_tagline TEXT,
        logo_path TEXT,
        signature_path TEXT,
        signatory_name TEXT,
        signatory_title TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        program_id INTEGER NOT NULL,
        full_name TEXT NOT NULL,
        ic_number TEXT NOT NULL,
        email TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
        UNIQUE(program_id, ic_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE certificates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        participant_id INTEGER NOT NULL,
        unique_code TEXT UNIQUE NOT NULL,
        certificate_number TEXT UNIQUE NOT NULL,
        pdf_path TEXT,
        qr_data TEXT,
        verification_hash TEXT,
        is_verified INTEGER DEFAULT 0,
        verification_count INTEGER DEFAULT 0,
        last_verified_at TEXT,
        generated_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.insert('settings', {'key': 'secret_key', 'value': AppConstants.defaultSecretKey});
    await db.insert('settings', {'key': 'theme', 'value': 'light'});
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE programs ADD COLUMN language TEXT DEFAULT 'bilingual'");
    }
    if (oldVersion < 3) {
      // Add new columns for enhanced certificate features
      await db.execute("ALTER TABLE programs ADD COLUMN expiry_date TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN signature_path_2 TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN signatory_name_2 TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN signatory_title_2 TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN signature_path_3 TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN signatory_name_3 TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN signatory_title_3 TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN watermark_text TEXT");
      await db.execute("ALTER TABLE programs ADD COLUMN watermark_opacity REAL DEFAULT 0.1");
      await db.execute("ALTER TABLE programs ADD COLUMN qr_position TEXT DEFAULT 'bottom-right'");
      
      // Add revocation columns to certificates
      await db.execute("ALTER TABLE certificates ADD COLUMN is_revoked INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE certificates ADD COLUMN revoked_at TEXT");
      await db.execute("ALTER TABLE certificates ADD COLUMN revocation_reason TEXT");
    }
    if (oldVersion < 4) {
      // Add custom templates table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_templates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          thumbnail TEXT,
          elements TEXT NOT NULL,
          canvas_width REAL DEFAULT 595,
          canvas_height REAL DEFAULT 842,
          background_color TEXT DEFAULT '#FFFFFF',
          background_image TEXT,
          background_fit TEXT DEFAULT 'cover',
          created_at TEXT,
          updated_at TEXT
        )
      ''');
      // Add custom_template_id to programs
      await db.execute("ALTER TABLE programs ADD COLUMN custom_template_id INTEGER");
    }
    if (oldVersion < 5) {
      // Add background image columns to custom_templates
      await db.execute("ALTER TABLE custom_templates ADD COLUMN background_image TEXT");
      await db.execute("ALTER TABLE custom_templates ADD COLUMN background_fit TEXT DEFAULT 'cover'");
    }
    if (oldVersion < 6) {
      // Add language column to custom_templates
      await db.execute("ALTER TABLE custom_templates ADD COLUMN language TEXT DEFAULT 'malay'");
    }
    if (oldVersion < 7) {
      // Add show_ic_number column to programs
      await db.execute("ALTER TABLE programs ADD COLUMN show_ic_number INTEGER DEFAULT 0");
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  Future<void> factoryReset() async {
    final db = await database;
    
    // Padam semua data dari tables
    await db.delete('certificates');
    await db.delete('participants');
    await db.delete('programs');
    await db.delete('settings');
    
    // Set semula settings asal
    await db.insert('settings', {'key': 'secret_key', 'value': AppConstants.defaultSecretKey});
    await db.insert('settings', {'key': 'theme', 'value': 'light'});
    await db.insert('settings', {'key': 'language', 'value': 'ms'});
  }
}
