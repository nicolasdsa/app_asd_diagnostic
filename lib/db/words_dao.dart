import 'package:app_asd_diagnostic/db/database.dart';

class WordsDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'palavra VARCHAR(20), '
      'modo VARCHAR(10), '
      'imagem VARCHAR(50), '
      'audio VARCHAR(50), '
      'dica VARCHAR(10)) ';

  static const String _tableName = 'words';

  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getWords() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return maps;
  }
}
