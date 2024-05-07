import 'package:app_asd_diagnostic/db/database.dart';

class TypeQuestionDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT)';

  static const String _tableName = 'type_questions';

  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result;
  }

  Future<String?> getTypeQuestionName(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tableName,
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String?;
    }
    return null;
  }
}
