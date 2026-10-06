import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase.instanceForTest() {
     _isTest = true;
  }
  bool _isTest = false;

  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    String dbPath = 'aniweb.db';
    if (!_isTest) {
      final dir = await getApplicationDocumentsDirectory();
      dbPath = p.join(dir.path, 'aniweb.db');
    }

    _db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await _createV1(db);
        await _createV2(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createV2(db);
        }
      },
    );
    return _db!;
  }

  Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE downloads (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        source_url TEXT NOT NULL,
        file_path TEXT NOT NULL,
        status TEXT NOT NULL,
        progress REAL NOT NULL,
        downloaded_bytes INTEGER NOT NULL,
        total_bytes INTEGER,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createV2(Database db) async {
    await db.execute('''
      CREATE TABLE website_shortcuts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        favicon_url TEXT,
        category TEXT,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE website_bookmark_groups (
        id TEXT PRIMARY KEY,
        website_name TEXT NOT NULL,
        domain TEXT NOT NULL UNIQUE,
        favicon TEXT,
        created_at TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE page_bookmarks (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        title TEXT NOT NULL,
        url TEXT NOT NULL UNIQUE,
        domain TEXT NOT NULL,
        favicon TEXT,
        thumbnail TEXT,
        date_added TEXT NOT NULL,
        last_visited TEXT,
        custom_title TEXT,
        notes TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (group_id) REFERENCES website_bookmark_groups (id) ON DELETE CASCADE
      )
    ''');
  }
}
