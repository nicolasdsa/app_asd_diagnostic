import 'package:app_asd_diagnostic/db/database.dart';

class HitRunObjectDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'path TEXT, '
      'name TEXT, '
      'objects TEXT)';

  static const String _tableName = 'hit_run_objects';
  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result;
  }
}
