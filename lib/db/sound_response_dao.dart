import 'package:app_asd_diagnostic/db/database.dart';

class SoundResponseDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'sound_id INTEGER,'
      'form_id INTEGER, '
      'text_response TEXT,'
      'FOREIGN KEY(sound_id) REFERENCES sounds(id))';

  static const String _tableName = 'sound_text_response';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertResponse(Map<String, dynamic> response) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, response);
  }

  Future<List<Map<String, Object?>>> getResponsesForForm(int formId) async {
    final db = await dbHelper.database;
    final sounds = await db.rawQuery('''
      SELECT sound_text_response.*, sounds.name
      FROM $_tableName
      INNER JOIN sounds ON sound_text_response.sound_id = sounds.id
      WHERE form_id = ?
    ''', [formId]);
    return sounds;
  }
}
