import 'dart:convert';

import 'package:click_campus_admin/data/db_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AppData {
  static final AppData _singleton = new AppData._internal();
  static const String TABLE_NAME = "app_users";
  Database _db;
  SharedPreferences _prefs;

  factory AppData() {
    return _singleton;
  }

  AppData._internal();

  Future<void> _init() async {
    if (_db != null) {
      return;
    }
    _db = await DBProvider.db.database;
  }

  Future<Database> getDb() async {
    await _init();
    return _db;
  }

  Future<void> getPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<String> getSchoolUrl() async {
    await getPrefs();
    return _prefs.getString("school_url") ?? null;
  }

  Future<String> getSchoolId() async {
    await getPrefs();
    return _prefs.getString("school_id") ?? null;
  }

  Future<void> setSchoolUrl(String url, String schoolId) async {
    await getPrefs();
    _prefs.setString("school_url", url);
    _prefs.setString("school_id", schoolId);
    return null;
  }

  Future<bool> areWeLoggedIn() async {
    int users = await getUserCount();
    if (users > 0) {
      return true;
    }
    return false;
  }

  Future<int> getUserCount() async {
    await _init();
    var rs = await _db.rawQuery("SELECT COUNT(login_id) FROM $TABLE_NAME;");
    int count = rs[0]["COUNT(login_id)"];
    return count;
  }

  Future<int> getUserLoginId() async {
    await _init();
    var rs = await _db.rawQuery("SELECT login_id FROM $TABLE_NAME;");
    if (rs.length > 0) {
      int loginId = rs[0]["login_id"];
      return loginId;
    }
    return 0;
  }

  Future<String> getSessionToken() async {
    await _init();
    var rs = await _db.rawQuery("SELECT active_session FROM $TABLE_NAME;");
    if (rs.length > 0) {
      String sessionToken = rs[0]["active_session"];
      return sessionToken;
    }
    return null;
  }

  Future<bool> deleteAllUsers() async {
    await clearSharedPrefs();
    await _init();
    var rs = await _db.rawDelete("DELETE FROM $TABLE_NAME;");
    if (rs > 0) {
      return true;
    }
    return false;
  }

  Future<void> saveUsersData(Map<String, dynamic> usersData) async {
    await _init();
    var batch = _db.batch();
    batch.delete(TABLE_NAME);
    batch.insert(TABLE_NAME, usersData);
    await batch.commit(noResult: true);
    //print("INSERTED USERS DATA");
  }

  Future<void> setImpersonatedSchoolId(String schoolId) async {
    await getPrefs();
    _prefs.setString("impersonated_school", schoolId);
    return null;
  }

  Future<String> getImpersonatedSchool() async {
    await getPrefs();
    return _prefs.getString("impersonated_school") ?? null;
  }

  Future<void> setStucareEmpId(String stucareEmpId) async {
    await getPrefs();
    _prefs.setString("stucare_emp_id", stucareEmpId);
    return null;
  }

  Future<String> getStucareEmpId() async {
    await getPrefs();
    return _prefs.getString("stucare_emp_id") ?? null;
  }

  Future<void> saveModulesOffline(String data) async {
    await getPrefs();
    _prefs.setString("active_modules", data);
    return null;
  }

  Future<String> getActiveModules() async {
    await getPrefs();
    return _prefs.getString("active_modules") ?? null;
  }

  Future<void> clearSharedPrefs() async {
    await getPrefs();
    await _prefs.clear();
    return null;
  }

  Future<void> clearDatabase() async {
    await _init();
    await _db.rawDelete("DELETE FROM $TABLE_NAME;");
    await _db.rawDelete("DELETE FROM classes;");
    await _db.rawDelete("DELETE FROM sections;");
    await _db.rawDelete("DELETE FROM sessions;");
    await _db.rawDelete("DELETE FROM messages;");
    await _db.rawDelete("DELETE FROM attendance_student;");
    await _db.rawDelete("DELETE FROM attendance_student_updates;");
    await _db.rawDelete("DELETE FROM master_school_info;");
    return null;
  }

  Future<void> storeAvailableSchools(String schoolId, String schoolUrl) async {
    await getPrefs();
    var alreadySavedSchools = _prefs.getString("availableSchools");
    var alreadySavedSchoolsParsed = jsonDecode(alreadySavedSchools ?? "{}");
    if (alreadySavedSchoolsParsed != null && !alreadySavedSchoolsParsed.containsKey(schoolId)) {
      alreadySavedSchoolsParsed[schoolId] = {
        'schoolId': schoolId,
        'schoolUrl': schoolUrl
      };
    }
    await _prefs.setString(
        "availableSchools", jsonEncode(alreadySavedSchoolsParsed));
    return null;
  }

  Future<Map<String, dynamic>> getAvailableSchools() async {
    await getPrefs();
    var alreadySavedSchools = _prefs.getString("availableSchools");
    var alreadySavedSchoolsParsed = jsonDecode(alreadySavedSchools ?? "{}");
    return alreadySavedSchoolsParsed;
  }

  Future<void> storeSchoolUsers(String schoolId, Map<String, dynamic> usersData) async {
    await getPrefs();
    var alreadySavedUsers = _prefs.getString("schoolsUsers");
    var alreadySavedUsersParsed = jsonDecode(alreadySavedUsers ?? "{}");
    if (!alreadySavedUsersParsed.containsKey(schoolId)) {
      alreadySavedUsersParsed[schoolId] = usersData;
    }
    await _prefs.setString("schoolsUsers", jsonEncode(alreadySavedUsersParsed));
    return null;
  }

  Future<Map<String, dynamic>> getSchoolUser(String schoolId) async {
    await getPrefs();
    var alreadySavedUsers = _prefs.getString("schoolsUsers");
    var alreadySavedUsersParsed = jsonDecode(alreadySavedUsers) as Map<String, dynamic>;
    if (alreadySavedUsersParsed.containsKey(schoolId)) {
      return alreadySavedUsersParsed[schoolId];
    }
    return null;
  }

  Future<String> getAvailableSchoolUrl(String schoolId) async {
    await getPrefs();
    var alreadySavedSchools = _prefs.getString("availableSchools");
    var alreadySavedSchoolsParsed =
    jsonDecode(alreadySavedSchools) as Map<String, dynamic>;
    if (alreadySavedSchoolsParsed.containsKey(schoolId)) {
      return alreadySavedSchoolsParsed[schoolId]['schoolUrl'];
    }
    return null;
  }

  Future<String> getCurrentlyActiveSchool() async {
    await getPrefs();
    return _prefs.getString("active_school");
  }

  Future<bool> setCurrentlyActiveSchool(String schoolId) async {
    await getPrefs();
    await _prefs.setString("active_school", schoolId);
    var user = await getSchoolUser(schoolId);
    if(user.length > 0){
      await clearDatabase();
      await saveUsersData(user);
      await AppData().setSchoolUrl(await getAvailableSchoolUrl(schoolId), schoolId);
      return true;
    }

    return false;
  }

  Future<String> getAccessKey() async {
    await getPrefs();
    return _prefs.getString("access_key") ?? null;
  }

  Future<void> setAccessKey(String accessKey) async {
    await getPrefs();
    _prefs.setString("access_key", accessKey);
    return null;
  }

  Future<String> getSecretKey() async {
    await getPrefs();
    return _prefs.getString("secret_key") ?? null;
  }

  Future<void> setSecretKey(String accessKey) async {
    await getPrefs();
    _prefs.setString("secret_key", accessKey);
    return null;
  }

  Future<String> getBucketName() async {
    await getPrefs();
    return _prefs.getString("aws_bucket_name") ?? null;
  }

  Future<void> setBucketName(String bucketName) async {
    await getPrefs();
    _prefs.setString("aws_bucket_name", bucketName);
    return null;
  }

  Future<String> getBucketRegion() async {
    await getPrefs();
    return _prefs.getString("aws_bucket_region") ?? null;
  }

  Future<void> setBucketRegion(String region) async {
    await getPrefs();
    _prefs.setString("aws_bucket_region", region);
    return null;
  }

  Future<String> getBucketUrl() async {
    await getPrefs();
    return _prefs.getString("aws_bucket_url") ?? null;
  }

  Future<void> setBucketUrl(String url) async {
    await getPrefs();
    _prefs.setString("aws_bucket_url", url);
    return null;
  }


}
