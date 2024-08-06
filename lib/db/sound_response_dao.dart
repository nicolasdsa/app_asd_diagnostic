import 'package:app_asd_diagnostic/db/database.dart';

class SoundResponseDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'sound_id INTEGER,'
      'form_id INTEGER, '
      'text_response TEXT,'
      'FOREIGN KEY(sound_id) REFERENCES sounds(id))'; // Corrigido aqui

  static const String _tableName = 'sound_text_response';

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
