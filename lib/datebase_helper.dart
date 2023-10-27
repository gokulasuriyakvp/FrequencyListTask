import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'TaskListDB.db';
  static const _databaseVersion = 1;

  static const frequencyTable = 'frequency_table';
  static const taskTable = 'task_table';

  static const columnId = '_id';
  static const columnFrequency = 'frequency';
  static const columnTask = 'task';
  static const columnPriority = 'priority';
  static const columnStatus = 'status';

  late Database _db;

  Future<void> initialization() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database database, int version) async {
    await database.execute('''
    CREATE TABLE $frequencyTable (
    $columnId INTEGER PRIMARY KEY,
    $columnFrequency TEXT)
    ''');

    await database.execute('''
    CREATE TABLE $taskTable (
    $columnId INTEGER PRIMARY KEY,
    $columnTask TEXT,
    $columnFrequency TEXT,
    $columnPriority TEXT,
    $columnStatus TEXT)
    ''');
  }

  Future _onUpgrade(Database database, int oldVersion, int newVersion) async {
    await database.execute('drop table $frequencyTable');
    await database.execute('drop table $taskTable');
    _onCreate(database, newVersion);
  }

  Future<int> insertData(Map<String, dynamic> row, String tableName) async {
    return await _db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    return await _db.query(tableName);
  }

  Future<int> updateData(Map<String, dynamic> row, String tableName) async {
    int id = row[columnId];
    return await _db.update(
      tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteData(int id, String tableName) async {
    return await _db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  readDataByColumnName(table, columnName, columnValue) async {
    return await _db
        .query(table, where: '$columnName =?', whereArgs: [columnValue]);
  }

  readDataById(table, itemId) async {
    return await _db.query(
      table,
      where: '_id=?',
      whereArgs: [itemId],
    );
  }
}
