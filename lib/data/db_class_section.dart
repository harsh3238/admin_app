
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/util_widgets/select_class_section.dart';
import 'package:sqflite/sqflite.dart';

class DbClassSection {
  static final DbClassSection _singleton = new DbClassSection._internal();
  static const String _CLASS_TABLE = "classes";
  static const String _SECTION_TABLE = "sections";
  Database _db;

  factory DbClassSection() {
    return _singleton;
  }

  DbClassSection._internal();

  Future<void> _init() async {
    if (_db != null) {
      return;
    }
    _db = await AppData().getDb();
  }

  Future<String> insertClassesSections(List<dynamic> classes, List<dynamic> sections) async {
    //print("INSERTING CLASSES AND SECTIONS");
    await _init();
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
    await _init();
    List<Map<String, dynamic>> rs = await _db.query(_CLASS_TABLE, orderBy: "class_order");
    if (rs.length > 0) {
      return rs;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllSections() async {
    await _init();
    List<Map<String, dynamic>> rs = await _db.query(_SECTION_TABLE, orderBy: "sec_seq");
    if (rs.length > 0) {
      return rs;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSectionsByClassId(int classId) async {
    await _init();
    List<Map<String, dynamic>> rs = await _db.query(_SECTION_TABLE, where: "class_id = ?", whereArgs: [classId], orderBy: "sec_seq");
    if (rs.length > 0) {
      return rs;
    }
    return [];
  }

  Future<List<ClassesWithSections>> getClassesWithSection() async {
    await _init();
    List<Map<String, dynamic>> rs =
    await _db.query(_CLASS_TABLE, orderBy: "class_order");

    List<ClassesWithSections> classSectionList = List();

    for (int i = 0; i < rs.length; i++) {
      List<Map<String, dynamic>> rs2 = await _db.query(_SECTION_TABLE,
          where: "class_id = ?", whereArgs: [rs[i]['id']], orderBy: "sec_seq");

      List<SectionItem> sections = [];
      rs2.forEach((section) {
        sections.add(SectionItem(section['id'], section['sec_name']));
      });
      classSectionList
          .add(ClassesWithSections(rs[i]['id'], rs[i]['class_name'], sections));
    }
    return classSectionList;
  }

  Future<List<Map<String, dynamic>>> getClassesForSection(
      String sections) async {
    await _init();
    List<Map<String, dynamic>> rs = await _db.rawQuery("SELECT id as section_id, class_id from $_SECTION_TABLE WHERE id in ($sections)");
    if (rs.length > 0) {
      return rs;
    }
    return [];
  }

}
