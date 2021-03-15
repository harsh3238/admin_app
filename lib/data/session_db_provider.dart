
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/the_session.dart';
import 'package:sqflite/sqflite.dart';

class SessionDbProvider {
  static final SessionDbProvider _singleton = new SessionDbProvider._internal();
  static const String _TABLE = "sessions";
  Database _db;

  factory SessionDbProvider() {
    return _singleton;
  }

  SessionDbProvider._internal();

  Future<void> _init() async {
    if (_db != null) {
      return;
    }
    _db = await AppData().getDb();
  }

  Future<String> insertSession(List<dynamic> sessions) async {
    //print("INSERTING SESSIONS");
    await _init();
    var batch = _db.batch();
    batch.delete(_TABLE);
    sessions.forEach((item){
      item['active_session'] = item['default_session'];
      batch.insert(_TABLE, item);
    });

    await batch.commit(noResult: true);
    //print("INSERTED SESSIONS");
    return null;
  }

  Future<TheSession> getDefaultSession() async {
    await _init();
    List<Map<String, dynamic>> rs = await _db.query(_TABLE, where: "default_session = 1");
    if (rs.length > 0) {
      return TheSession.fromJson(rs[0]);
    }
    return null;
  }

  Future<TheSession> getActiveSession() async {
    await _init();
    List<Map<String, dynamic>> rs = await _db.query(_TABLE, where: "active_session = 1");
    if (rs.length > 0) {
      return TheSession.fromJson(rs[0]);
    }
    return null;
  }

  Future<List<TheSession>> getAllSessions() async {
    await _init();
    List<Map<String, dynamic>> rs = await _db.query(_TABLE);
    if (rs.length > 0) {
      List<TheSession> list = List();
      rs.forEach((i){
        list.add(TheSession.fromJson(i));
      });
      return list;
    }
    return null;
  }

  Future<TheSession> setActiveSession(int sessionId) async {
    await _init();
    var batch = _db.batch();
    batch.rawUpdate("UPDATE $_TABLE SET active_session = 0");
    batch.rawUpdate("UPDATE $_TABLE SET active_session = 1 WHERE session_id = $sessionId");

    await batch.commit(noResult: false);
    return null;
  }


}
