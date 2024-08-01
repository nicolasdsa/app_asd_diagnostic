import 'package:app_asd_diagnostic/db/database.dart';

class JsonDataResponseDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'form_id INTEGER, '
      'id_patient INTEGER, '
      'start_date TEXT, '
      'end_date TEXT, '
      'game TEXT, '
      'FOREIGN KEY (form_id) REFERENCES forms(id))';

  static const String _tableName = 'json_data_responses';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertResponse(Map<String, dynamic> response) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, response);
  }

  Future<List<Map<String, dynamic>>> getResponsesForForm(int formId) async {
    final db = await dbHelper.database;
    return await db.query(
      _tableName,
      where: 'form_id = ?',
      whereArgs: [formId],
    );
  }
}
