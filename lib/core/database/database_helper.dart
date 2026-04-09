import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();

    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'cattle_manager.db');

    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSchema(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS health_records');
    await db.execute('DROP TABLE IF EXISTS breeding_records');
    await db.execute('DROP TABLE IF EXISTS milk_logs');
    await db.execute('DROP TABLE IF EXISTS expense_logs');
    await db.execute('DROP TABLE IF EXISTS milk_sales');
    await db.execute('DROP TABLE IF EXISTS cows');
    await _createSchema(db);
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE cows (
        local_id TEXT PRIMARY KEY,
        server_id TEXT UNIQUE,
        sync_action TEXT NOT NULL DEFAULT 'synced',
        tag_number TEXT NOT NULL,
        breed TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        source TEXT NOT NULL DEFAULT 'bought',
        date_of_birth TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE milk_logs (
        local_id TEXT PRIMARY KEY,
        server_id TEXT UNIQUE,
        sync_action TEXT NOT NULL DEFAULT 'synced',
        cow_local_id TEXT NOT NULL,
        log_date TEXT NOT NULL,
        litres REAL NOT NULL DEFAULT 0,
        period TEXT NOT NULL DEFAULT 'morning',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_error TEXT,
        UNIQUE(cow_local_id, log_date, period),
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_records (
        local_id TEXT PRIMARY KEY,
        server_id TEXT UNIQUE,
        sync_action TEXT NOT NULL DEFAULT 'synced',
        cow_local_id TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        drug_used TEXT,
        record_date TEXT NOT NULL,
        next_due_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_error TEXT,
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE breeding_records (
        local_id TEXT PRIMARY KEY,
        server_id TEXT UNIQUE,
        sync_action TEXT NOT NULL DEFAULT 'synced',
        cow_local_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        event_date TEXT NOT NULL,
        expected_calving_date TEXT,
        calf_tag_number TEXT,
        calf_breed TEXT,
        calf_date_of_birth TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_error TEXT,
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_logs (
        local_id TEXT PRIMARY KEY,
        server_id TEXT UNIQUE,
        sync_action TEXT NOT NULL DEFAULT 'synced',
        cow_local_id TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_error TEXT,
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE milk_sales (
        local_id TEXT PRIMARY KEY,
        server_id TEXT UNIQUE,
        sync_action TEXT NOT NULL DEFAULT 'synced',
        sale_date TEXT NOT NULL,
        litres_sold REAL NOT NULL,
        price_per_litre REAL NOT NULL,
        total_amount REAL NOT NULL,
        buyer TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_error TEXT
      )
    ''');
  }
}
