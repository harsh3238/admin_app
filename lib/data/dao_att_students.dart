import 'package:click_campus_admin/views/attendance/students/mark_attendance/sort_dialog.dart';
import 'package:sqflite/sqflite.dart';

import 'app_data.dart';

class DaoAttStudents {
  static final DaoAttStudents _singleton = new DaoAttStudents._internal();
  static const String _TB_NAME = "attendance_student";

  Database _db;

  factory DaoAttStudents() {
    return _singleton;
  }

  DaoAttStudents._internal();

  Future<void> _init() async {
    if (_db != null) {
      return;
    }
    _db = await AppData().getDb();
  }

  Future<String> insertStudents(List<dynamic> students) async {
    //print("INSERTING ATTENDANCE STUDENTS");
    if(students.length > 0){
      await _init();
      var batch = _db.batch();
      batch.delete(_TB_NAME,
          where: "class_id = ? AND section_id = ?",
          whereArgs: [students[0]['class_id'], students[0]['section_id']]);
      students.forEach((item) {
        Map<String, dynamic> i = item;
        if (i.containsKey('absent_reason')) {
          i.remove('absent_reason');
        }
        if (i.containsKey('address')) {
          i.remove('address');
        }
        batch.insert(_TB_NAME, item);
      });
      await batch.commit(noResult: true);
      //print("INSERTED ATTENDANCE STUDENTS");
    }
    return null;
  }

  Future<int> getStudentCount(int classId, int sectionId) async {
    await _init();
    var rs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id =$sectionId;");
    return rs[0]["COUNT(s_r_no)"] ?? 0;
  }

  Future<List<Map<String, dynamic>>> getStudents(int classId, int sectionId,
      {SortBy orderBy = SortBy.name, SortOrder order = SortOrder.asc}) async {
    await _init();

    String sortByValue;
    String sortOrderValue;
    if (orderBy == SortBy.name) {
      sortByValue = "student_name";
    } else {
      sortByValue = "roll_no";
    }
    if (order == SortOrder.asc) {
      sortOrderValue = "asc";
    } else {
      sortOrderValue = "desc";
    }

    List<Map<String, dynamic>> rs = await _db.query(
      _TB_NAME,
      where: "class_id = ? AND section_id = ?",
      whereArgs: [classId, sectionId],
      orderBy: "$sortByValue $sortOrderValue",
    );
    if (rs.length > 0) {
      return rs;
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchStudent(
      int classId, int sectionId, String searchQuery) async {
    await _init();

    List<Map<String, dynamic>> rs = await _db.query(
      _TB_NAME,
      where:
          "class_id = ? AND section_id = ? AND student_name LIKE '%$searchQuery%'",
      whereArgs: [classId, sectionId],
    );
    if (rs.length > 0) {
      return rs;
    }
    return [];
  }

  Future<Map<String, bool>> getWholeClassAttendanceStatus(
      int classId, int sectionId) async {
    await _init();
    bool allPresent = false;
    bool allAbsent = false;
    bool allLeave = false;
    var allStuCountRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id =$sectionId;");
    int allStuCount = allStuCountRs[0]["COUNT(s_r_no)"] ?? 0;

    var allPresentStuCountRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id =$sectionId AND att_status = 'P';");
    int allPresentStuCount = allPresentStuCountRs[0]["COUNT(s_r_no)"] ?? 0;

    var allAbsentStuCountRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id =$sectionId AND att_status = 'AB';");

    int allAbsentStuCount = allAbsentStuCountRs[0]["COUNT(s_r_no)"] ?? 0;

    var allLeaveStuCountRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id =$sectionId AND att_status = 'LV';");

    int allLeaveStuCount = allLeaveStuCountRs[0]["COUNT(s_r_no)"] ?? 0;

    if (allStuCount != 0 && allStuCount == allPresentStuCount) {
      allPresent = true;
    }
    if (allStuCount != 0 && allStuCount == allAbsentStuCount) {
      allAbsent = true;
    }
    if (allStuCount != 0 && allStuCount == allLeaveStuCount) {
      allLeave = true;
    }

    return {'all_p': allPresent, 'all_a': allAbsent, 'all_l': allLeave};
  }

  Future<void> setAttendanceStatusWholeClass(
      int classId, int sectionId, String status) async {
    await _init();
    await _db.update(_TB_NAME, {'att_status': status},
        where: "class_id =? AND section_id =?",
        whereArgs: [classId, sectionId]);
    return null;
  }

  Future<void> setAttendanceStatusStudent(String srNo, String status) async {
    await _init();
    await _db.update(_TB_NAME, {'att_status': status},
        where: "s_r_no = ?", whereArgs: [srNo]);
    return null;
  }

  Future<bool> isAttendanceMarked(int classId, int sectionId) async {
    await _init();
    var allStuCountRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id = $sectionId;");
    int allStuCount = allStuCountRs[0]["COUNT(s_r_no)"] ?? 0;

    var allMarkedStuCountRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id = $sectionId AND length(att_status) > 0;");
    int allMarkedStuCount = allMarkedStuCountRs[0]["COUNT(s_r_no)"] ?? 0;

    if (allStuCount != 0 && allStuCount == allMarkedStuCount) {
      return true;
    }

    return false;
  }

  Future<bool> leaveValidations(int classId, int sectionId) async {
    await _init();
    var leaveNotSelectedRs = await _db.rawQuery(
        "SELECT COUNT(s_r_no) FROM $_TB_NAME WHERE class_id = $classId AND section_id = $sectionId AND att_status = 'LV' AND leave_id IS NULL;");
    int countOfEntriesWhereLeaveIdIsNull =
        leaveNotSelectedRs[0]["COUNT(s_r_no)"] ?? 0;

    if (countOfEntriesWhereLeaveIdIsNull > 0) {
      return false;
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> getAttToSubmit(
      int classId, int sectionId) async {
    await _init();
    int userLoginId = await AppData().getUserLoginId();
    List<Map<String, dynamic>> rs = await _db.query(_TB_NAME,
        columns: [
          'stucare_id',
          'class_id',
          'section_id',
          'att_date',
          'att_status',
          '$userLoginId as created_by'
        ],
        where: "class_id = ? AND section_id = ?",
        whereArgs: [classId, sectionId]);
    if (rs.length > 0) {
      return rs;
    }
    return [];
  }

  Future<void> setLeaveId(int stucareId, int leaveId) async {
    await _init();
    await _db.update(_TB_NAME, {'leave_id': leaveId},
        where: "stucare_id = ?", whereArgs: [stucareId]);
    return null;
  }

  Future<void> deleteAll(int classId, int sectionId) async {
    await _init();
    await _db.delete(_TB_NAME,
        where: "class_id = ? AND section_id = ?",
        whereArgs: [classId, sectionId]);
    return null;
  }
}
