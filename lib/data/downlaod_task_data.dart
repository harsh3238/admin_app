
import 'package:click_campus_admin/data/task_db_provider.dart';
import 'package:sqflite/sqflite.dart';

class DownloadTasks {
  static final DownloadTasks _singleton = new DownloadTasks._internal();
  static const String TABLE_NAME = "task";
  Database _db;

  factory DownloadTasks() {
    return _singleton;
  }

  DownloadTasks._internal();

  Future<void> _init() async {
    if (_db != null) {
      return;
    }
    _db = await TaskDbProvider.db.database;
  }

  Future<String> getTaskIdForFile(String fileUrl) async {
    await _init();
    var rs = await _db.rawQuery("SELECT task_id FROM $TABLE_NAME WHERE url = '$fileUrl';");
    if(rs.length > 0){
      String taskId = rs[0]["task_id"];
      if(taskId != null &&  taskId.length > 0){
        return taskId;
      }
    }
    return null;
  }

  Future<int> getTaskStatus(String taskId) async {
    await _init();
    var rs = await _db.rawQuery("SELECT status FROM $TABLE_NAME WHERE task_id = '$taskId';");
    if(rs.length > 0){
      int status = rs[0]["status"];
      if(taskId != null &&  taskId.length > 0){
        return status;
      }
    }
    return null;
  }
}
