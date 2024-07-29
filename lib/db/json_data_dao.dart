import 'dart:convert';

import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/json_data.dart';

class JsonDataDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'json TEXT, '
      'game TEXT, '
      'created_at TIMESTAMP, '
      'updated_at TIMESTAMP, '
      'id_patient INTEGER)';

  static const String _tableName = 'json_data';
  static const String _json = 'json';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertJson(
      Map<String, dynamic> json, String idPatient, String game) async {
    final db = await dbHelper.database;
    final jsonInsert = jsonEncode(json);
    final DateTime now = DateTime.now();

    final String createdAt = now.toIso8601String();
    final String updatedAt = now.toIso8601String();

    return await db.insert('json_data', {
      "json": jsonInsert,
      "id_patient": idPatient,
      "game": game,
      'created_at': createdAt,
      'updated_at': updatedAt
    });
  }

  Future<List<JsonData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<JsonData> data = await toList(result);
    return data;
  }

  Future<List<List<dynamic>>> getAllJsonData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    Map<String, List<List<dynamic>>> groupedData = {};

    for (var map in maps) {
      Map<String, dynamic> jsonDecoded = jsonDecode(map[_json]);
      String createdAt = map['created_at'].toString();

      jsonDecoded.forEach((key, value) {
        if (!groupedData.containsKey(key)) {
          groupedData[key] = [];
        }
        groupedData[key]!.add([value.toString(), createdAt]);
      });
    }

    List<List<dynamic>> result = [];
    groupedData.forEach((key, values) {
      result.add([key, values]);
    });

    return result;
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

  Future<List<String>> getUniqueGamesByPatientId(String idPatient) async {
    final db = await dbHelper.database;
    // A consulta SQL seleciona a coluna 'game' da tabela, agrupando por 'game'
    // para garantir que cada jogo seja único para o 'id_patient' fornecido.
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT DISTINCT game FROM $_tableName WHERE id_patient = ? GROUP BY game',
      [idPatient],
    );

    // Converte os resultados em uma lista de strings (nomes dos jogos)
    final List<String> games =
        results.map((row) => row['game'] as String).toList();

    return games;
  }

  Future<List<Map<String, dynamic>>> getRowsByPatientIdAndGame(
      String idPatient, String gameName) async {
    final db = await dbHelper.database;
    // Executa a consulta na tabela, filtrando por 'id_patient' e 'game'
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'id_patient = ? AND game = ?',
      whereArgs: [idPatient, gameName],
    );

    return rows;
  }
}
