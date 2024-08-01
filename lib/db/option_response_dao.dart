import 'package:app_asd_diagnostic/db/database.dart';

class OptionResponseDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'form_id INTEGER, '
      'question_id INTEGER, '
      'option_id INTEGER, '
      'FOREIGN KEY (form_id) REFERENCES forms(id))';

  static const String _tableName = 'option_responses';

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
