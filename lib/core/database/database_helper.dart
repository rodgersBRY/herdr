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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cows (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        tag TEXT NOT NULL,
        name TEXT,
        breed TEXT,
        gender TEXT NOT NULL,
        birth_date TEXT,
        weight REAL,
        status TEXT NOT NULL DEFAULT 'active',
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE milk_logs (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        cow_local_id TEXT NOT NULL,
        log_date TEXT NOT NULL,
        morning_litres REAL NOT NULL DEFAULT 0,
        evening_litres REAL NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(cow_local_id, log_date),
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE health_records (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        cow_local_id TEXT NOT NULL,
        record_type TEXT NOT NULL,
        description TEXT NOT NULL,
        vet_name TEXT,
        cost REAL,
        record_date TEXT NOT NULL,
        next_due_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE breeding_records (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        cow_local_id TEXT NOT NULL,
        record_type TEXT NOT NULL,
        service_date TEXT,
        sire_name TEXT,
        sire_breed TEXT,
        pregnancy_check_date TEXT,
        pregnancy_result TEXT,
        expected_calving_date TEXT,
        actual_calving_date TEXT,
        calf_gender TEXT,
        calf_tag TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_logs (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        cow_local_id TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        expense_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(cow_local_id) REFERENCES cows(local_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE milk_sales (
        local_id TEXT PRIMARY KEY,
        server_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        sale_date TEXT NOT NULL,
        litres REAL NOT NULL,
        price_per_litre REAL NOT NULL,
        buyer_name TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
