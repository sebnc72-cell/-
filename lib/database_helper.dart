import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('parts_warehouse.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Збільшуємо версію до 3, щоб гарантовано додати carYear
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        article TEXT,
        quantity INTEGER,
        minQuantity INTEGER,
        price REAL,
        brand TEXT,
        carModel TEXT,
        carYear TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE parts ADD COLUMN category TEXT");
      await db.execute("ALTER TABLE parts ADD COLUMN minQuantity INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE parts ADD COLUMN price REAL DEFAULT 0.0");
    }
    if (oldVersion < 3) {
      // Додаємо поле року випуску/покоління до існуючих баз даних
      await db.execute("ALTER TABLE parts ADD COLUMN carYear TEXT");
    }
  }

  Future<int> insertPart(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('parts', row);
  }

  Future<List<Map<String, dynamic>>> fetchParts() async {
    final db = await database;
    return await db.query('parts', orderBy: 'id DESC');
  }

  Future<int> updatePart(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update('parts', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePart(int id) async {
    final db = await database;
    return await db.delete('parts', where: 'id = ?', whereArgs: [id]);
  }
}
