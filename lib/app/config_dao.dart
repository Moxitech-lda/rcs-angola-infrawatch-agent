import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class ConfigDAO {
  Future<void> setConfig(String key, String value) async {
    final db = await DBHelper.instance.database;
    await db.insert("Configs", {
      "Key": key,
      "Value": value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getConfig(String key) async {
    final db = await DBHelper.instance.database;
    final result = await db.query(
      "Configs",
      where: "Key = ?",
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first["Value"] as String;
    }
    return null;
  }
}
