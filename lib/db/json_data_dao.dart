import 'package:app_asd_diagnostic/db/database.dart';

class JsonDataDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'json TEXT, '
      'created_at TIMESTAMP, '
      'updated_at TIMESTAMP, '
      'id_patient INTEGER)';

  static const String _tableName = 'json_data';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertJson(Map<String, dynamic> json) async {
    final db = await dbHelper.database;
    print(json);
    return await db.insert('json_data', json);
  }

  Future<List<Map<String, dynamic>>> getAllJsonData() async {
    final db = await dbHelper.database;
    return await db.query(_tableName);
  }
}
