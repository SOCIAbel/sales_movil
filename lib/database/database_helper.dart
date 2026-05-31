import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'sales.db';
  static const int _version = 3;
  static const String _clientsTable = 'clients';
  static const String _suppliersTable = 'suppliers';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_clientsTable (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        name             TEXT NOT NULL,
        document_number  TEXT NOT NULL,
        is_synced        INTEGER NOT NULL DEFAULT 0,
        server_id        INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_suppliersTable (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre    TEXT NOT NULL,
        ruc       TEXT NOT NULL,
        telefono  TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        server_id INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_clientsTable ADD COLUMN server_id INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $_suppliersTable (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre    TEXT NOT NULL,
          ruc       TEXT NOT NULL,
          telefono  TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0,
          server_id INTEGER
        )
      ''');
    }
  }

  // ─── CLIENTS ────────────────────────────────────────────

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(_clientsTable, row);
  }

  Future<int> update(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(_clientsTable, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return await db.query(_clientsTable, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> queryPending() async {
    final db = await database;
    return await db.query(_clientsTable, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> updateSynced(int id, int serverId) async {
    final db = await database;
    return await db.update(
      _clientsTable,
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSyncedOnly(int id) async {
    final db = await database;
    return await db.update(_clientsTable, {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(_clientsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_clientsTable);
  }

  // ─── SUPPLIERS ──────────────────────────────────────────

  Future<int> insertSupplier(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(_suppliersTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllSuppliers() async {
    final db = await database;
    return await db.query(_suppliersTable, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> queryPendingSuppliers() async {
    final db = await database;
    return await db.query(_suppliersTable, where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<int> updateSupplierSynced(int id, int serverId) async {
    final db = await database;
    return await db.update(
      _suppliersTable,
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSupplier(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      _suppliersTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete(_suppliersTable, where: 'id = ?', whereArgs: [id]);
  }
}