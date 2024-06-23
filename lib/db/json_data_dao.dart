import 'dart:convert';

import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/json_data.dart';

class JsonDataDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'json TEXT, '
      'created_at TIMESTAMP, '
      'updated_at TIMESTAMP, '
      'id_patient INTEGER)';

  static const String _tableName = 'json_data';
  static const String _json = 'json';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertJson(Map<String, dynamic> json) async {
    final db = await dbHelper.database;
    final jsonInsert = jsonEncode(json);
    return await db.insert('json_data', {"json": jsonInsert, "id_patient": 1});
  }

  Future<List<JsonData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<JsonData> data = await toList(result);
    return data;
  }

  Future<List<JsonData>> toList(List<Map<String, dynamic>> dataAll) async {
    final List<JsonData> allData = [];
    for (Map<String, dynamic> linha in dataAll) {
      final teste = jsonDecode(linha[_json]);
      final formattedData =
          teste.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      final JsonData data = JsonData(linha[_id], formattedData);
      allData.add(data);
    }
    return allData;
  }

  Future<JsonData> getOne(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id LIKE ?',
      whereArgs: ['%$id%'],
    );
    final teste = jsonDecode(result[0][_json]);
    final formattedData =
        teste.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    final JsonData data = JsonData(id, formattedData);
    return data;
  }
}
