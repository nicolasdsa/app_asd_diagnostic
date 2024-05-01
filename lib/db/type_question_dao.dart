import 'package:app_asd_diagnostic/db/database.dart';

class TypeQuestionDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT)';

  static const String _tableName = 'type_questions';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> type) async {
    final db = await dbHelper.database;
    return await db.insert('type_questions', type);
  }
}
