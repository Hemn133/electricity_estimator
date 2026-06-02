import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        units REAL NOT NULL,
        rebate REAL NOT NULL,
        total_charges REAL NOT NULL,
        final_cost REAL NOT NULL
      )
    ''');
  }

  Future<int> insertBill(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('bills', row);
  }

  Future<List<Map<String, dynamic>>> queryAllBills() async {
    final db = await instance.database;
    return await db.query('bills', orderBy: 'id DESC');
  }

  Future<int> updateBill(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('bills', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBill(int id) async {
    final db = await instance.database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }
}