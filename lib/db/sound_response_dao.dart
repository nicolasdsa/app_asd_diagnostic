import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/sound.dart';

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

  Future<List<SoundComponent>> getResponsesForForm(int formId) async {
    final db = await dbHelper.database;
    final sounds = await db.query(
      _tableName,
      where: 'form_id = ?',
      whereArgs: [formId],
    );
    return toList(sounds);
  }

  List<SoundComponent> toList(List<Map<String, dynamic>> soundsAll) {
    final List<SoundComponent> sounds = [];
    for (Map<String, dynamic> linha in soundsAll) {
      final sound = SoundComponent(
        soundId: linha['sound_id'],
        initialText: linha['text_response'],
      );

      sounds.add(sound);
    }
    return sounds;
  }
}
