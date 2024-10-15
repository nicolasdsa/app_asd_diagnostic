import 'dart:convert';

import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/json_data.dart';

class JsonDataDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'json TEXT, '
      'json_flag TEXT, '
      'json_flag_description TEXT, '
      'game TEXT, '
      'created_at TIMESTAMP, '
      'updated_at TIMESTAMP, '
      'id_patient INTEGER)';

  static const String _tableName = 'json_data';
  static const String _json = 'json';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertJson(
      Map<String, dynamic> json,
      String idPatient,
      String game,
      Map<String, dynamic> jsonFlag,
      Map<String, dynamic> jsonDescription) async {
    final db = await dbHelper.database;
    final jsonInsert = jsonEncode(json);
    final jsonFlagInsert = jsonEncode(jsonFlag);
    final jsonDescriptionInsert = jsonEncode(jsonDescription);

    final DateTime now = DateTime.now();

    final String createdAt = now.toIso8601String();
    final String updatedAt = now.toIso8601String();

    return await db.insert('json_data', {
      "json": jsonInsert,
      "json_flag": jsonFlagInsert,
      "json_flag_description": jsonDescriptionInsert,
      "id_patient": idPatient,
      "game": game,
      'created_at': createdAt,
      'updated_at': updatedAt
    });
  }

  Future<int> insert(Map<String, dynamic> json) async {
    final db = await dbHelper.database;

    return await db.insert('json_data', json);
  }

  Future<List<JsonData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<JsonData> data = await toList(result);
    return data;
  }

  Future<List<List<dynamic>>> getAllJsonDataByGameAndDate(
      String game, int idPatient, DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'game = ? AND id_patient = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        game,
        idPatient,
        startDate.toIso8601String(),
        endDate.toIso8601String()
      ],
      orderBy: 'created_at DESC',
    );

    Map<String, List<List<dynamic>>> groupedData = {};

    for (var map in rows) {
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

  Future<Map<String, List<List<dynamic>>>> getAllJsonDataGroupedByGame(
      int idPatient, DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'id_patient = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        idPatient,
        startDate.toIso8601String(),
        endDate.toIso8601String()
      ],
    );

    Map<String, Map<String, List<List<dynamic>>>> groupedData = {};

    for (var map in rows) {
      Map<String, dynamic> jsonDecoded = jsonDecode(map[_json]);
      String createdAt = map['created_at'].toString();
      String game = map['game'];

      if (!groupedData.containsKey(game)) {
        groupedData[game] = {};
      }

      jsonDecoded.forEach((key, value) {
        if (!groupedData[game]!.containsKey(key)) {
          groupedData[game]![key] = [];
        }
        groupedData[game]![key]!.add([value.toString(), createdAt]);
      });
    }

    return groupedData.map((key, value) =>
        MapEntry(key, value.entries.map((e) => [e.key, e.value]).toList()));
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

  Future<List<Map<String, dynamic>>> getJsonFlag(String idPatient,
      String gameName, DateTime startDate, DateTime endDate) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'game = ? AND id_patient = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        gameName,
        idPatient,
        startDate.toIso8601String(),
        endDate.toIso8601String()
      ],
    );

    return rows;
  }

  Future<List<Map<String, dynamic>>> getRowsByPatientIdAndGame(
      String idPatient, String gameName) async {
    final db = await dbHelper.database;
    // Executa a consulta na tabela, filtrando por 'id_patient' e 'game'
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where: 'id_patient = ? AND game = ?',
      whereArgs: [idPatient, gameName],
      orderBy: 'created_at DESC',
    );

    return rows;
  }

  Future<bool> exists(int patientId, String game, String createdAt) async {
    // Verificar no banco de dados se já existe um registro com o mesmo patientId, game e createdAt
    // Retorne true se existir, caso contrário false
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id_patient = ? AND game = ? AND created_at = ?',
      whereArgs: [patientId, game, createdAt],
    );

    return result.isNotEmpty; // Se a lista não estiver vazia, o registro existe
  }

  Future<List<Map<String, dynamic>>> exportJson(
      String idPatient, List<String> games, String createdAt) async {
    print(games);
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> rows = await db.query(
      _tableName,
      where:
          'id_patient = ? AND game IN (${games.map((game) => '?').join(', ')}) AND created_at >= ?',
      whereArgs: [idPatient, ...games, createdAt],
      orderBy: 'created_at DESC',
    );
    final List<Map<String, dynamic>> resultRows = [];

    for (var row in rows) {
      final resultRow = Map<String, dynamic>.from(row);

      if (row.containsKey('json')) {
        resultRow['json'] = jsonDecode(row['json']);
      }
      if (row.containsKey('json_flag_description')) {
        resultRow['json_flag_description'] =
            jsonDecode(row['json_flag_description']);
      }
      if (row.containsKey('json_flag')) {
        resultRow['json_flag'] = jsonDecode(row['json_flag']);
      }

      resultRows.add(resultRow);
    }

    return resultRows;
  }
}
