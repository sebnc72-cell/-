import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Змінили назву файлу, щоб створити нову таблицю з розширеними полями
    _database = await _initDB('parts_database_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Додали поля: article (артикул), quantity (кількість), isForZafira (позначка авто)
    await db.execute('''
    CREATE TABLE parts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      article TEXT,
      quantity INTEGER,
      isForZafira INTEGER
    )
    ''');
  }

  // Оновлений метод отримує цілий словник даних (Map) замість одного рядка
  Future<int> insertPart(Map<String, dynamic> partData) async {
    final db = await instance.database;
    return await db.insert('parts', partData);
  }

  Future<List<Map<String, dynamic>>> fetchParts() async {
    final db = await instance.database;
    return await db.query('parts');
  }
}
