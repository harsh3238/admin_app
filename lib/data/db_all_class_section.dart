import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBAllClassSection {
  static const String _CLASS_TABLE = "classes";
  static const String _SECTION_TABLE = "sections";
  static Database _database;
  static final DBAllClassSection db = DBAllClassSection._();
  DBAllClassSection._();

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database;
    // If database don't exists, create one
    _database = await initDB();
    return _database;
  }
  // Create the database and the Employee table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'class_sections.db');
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {

          await db.execute("create table classes " +
              "( " +
              "    id    int  not null, " +
              "    class_name  text not null, " +
              "    class_order int  not null " +
              ");");

          await db.execute("create table sections " +
              "( " +
              "id int not null, " +
              "sec_name text not null, " +
              "class_id int not null, " +
              "sec_seq int not null " +
              "); ");

        });
  }


  Future<String> insertClassesSections(List<dynamic> classes, List<dynamic> sections) async {
    //print("INSERTING CLASSES AND SECTIONS");
    final Database _db = await database;
    var batch = _db.batch();
    batch.delete(_CLASS_TABLE);
    batch.delete(_SECTION_TABLE);
    classes.forEach((item){
      batch.insert(_CLASS_TABLE, item);
    });

    sections.forEach((item){
      batch.insert(_SECTION_TABLE, item);
    });
    await batch.commit(noResult: true);
    //print("INSERTED CLASSES AND SECTIONS");
    return null;
  }


  Future<List<Map<String, dynamic>>> getAllClasses() async {
    final Database _db = await database;
    List<Map<String, dynamic>> rs = await _db.query(_CLASS_TABLE, orderBy: "class_order");
    if (rs.length > 0) {
      return rs;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllSections() async {
    final Database _db = await database;
    List<Map<String, dynamic>> rs = await _db.query(_SECTION_TABLE, orderBy: "sec_seq");
    if (rs.length > 0) {
      return rs;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSectionsByClassId(int classId) async {
    final Database _db = await database;
    List<Map<String, dynamic>> rs = await _db.query(_SECTION_TABLE, where: "class_id = ?", whereArgs: [classId], orderBy: "sec_seq");
    if (rs.length > 0) {
      return rs;
    }
    return [];
  }



}