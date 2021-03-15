import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskDbProvider {
  TaskDbProvider._();

  static final TaskDbProvider db = TaskDbProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "download_tasks.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},);
  }
}
