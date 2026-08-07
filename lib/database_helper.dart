import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Створюємо єдиний екземпляр класу для всього додатка (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Отримуємо доступ до бази даних
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('parts_database.db');
    return _database!;
  }

  // Ініціалізуємо (відкриваємо) файл бази даних
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Створюємо таблицю при першому запуску
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE parts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');
  }

  // Метод для додавання нової запчастини
  Future<int> insertPart(String name) async {
    final db = await instance.database;
    return await db.insert('parts', {'name': name});
  }

  // Метод для отримання всіх запчастин зі списку
  Future<List<Map<String, dynamic>>> fetchParts() async {
    final db = await instance.database;
    return await db.query('parts');
  }
}
