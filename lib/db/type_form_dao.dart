import 'package:app_asd_diagnostic/db/database.dart';

class TypeFormDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT)';

  static const String _tableName = 'type_forms';

  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result;
  }
}
