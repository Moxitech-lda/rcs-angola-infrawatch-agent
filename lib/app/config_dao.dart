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

class TypesDAO {
  Future<void> setType(String id, String value) async {
    final db = await DBHelper.instance.database;

    await db.insert("Types", {"Id": id, "Value": value});
  }

  Future<List<Types>> getAll() async {
    final db = await DBHelper.instance.database;
    final result = await db.query("Types");
    return result.map((e) => Types.fromMap(e)).toList();
  }
}

class Types {
  String id;
  String value;
  Types({required this.id, required this.value});

  Map<String, dynamic> toMap() => {"Id": id, "Value": value};

  factory Types.fromMap(Map<String, dynamic> map) {
    return Types(id: map["Id"], value: map["Value"]);
  }
}
