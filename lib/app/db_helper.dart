import 'package:agent_infra_watch/system.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _db;

  DBHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB("infra_watch.db");
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = join(InfraWatchFileSystem.basePath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Machines (
        Id TEXT PRIMARY KEY,
        Nome TEXT NOT NULL,
        IP TEXT NOT NULL,
        Usuario TEXT,
        Senha TEXT,
        TipoMonitoramento INTEGER NOT NULL,
        Ativo INTEGER NOT NULL,
        TipoDispositivo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Configs (
        Key TEXT PRIMARY KEY,
        Value TEXT
      )
    ''');
  }
}
