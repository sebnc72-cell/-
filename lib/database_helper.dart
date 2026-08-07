import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('parts_database_v5.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE parts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      article TEXT,
      quantity INTEGER,
      brand TEXT,
      carModel TEXT
    )
    ''');
  }

  Future<int> insertPart(Map<String, dynamic> partData) async {
    final db = await instance.database;
    return await db.insert('parts', partData);
  }

  Future<int> updatePart(Map<String, dynamic> partData) async {
    final db = await instance.database;
    return await db.update('parts', partData, where: 'id = ?', whereArgs: [partData['id']]);
  }

  Future<int> deletePart(int id) async {
    final db = await instance.database;
    return await db.delete('parts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> fetchParts() async {
    final db = await instance.database;
    return await db.query('parts');
  }
}
