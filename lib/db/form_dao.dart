import 'package:app_asd_diagnostic/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FormDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT)';

  static const String _tableName = 'forms';

  Future<int> insertForm(Map<String, dynamic> form) async {
    final Database database = await getDatabase();
    return await database.insert('forms', form);
  }

  Future<List<Map<String, dynamic>>> getAllForms() async {
    final Database database = await getDatabase();
    return await database.query('forms');
  }

  Future<int> updateForm(Map<String, dynamic> form) async {
    final Database database = await getDatabase();
    return await database.update(
      'forms',
      form,
      where: 'id = ?',
      whereArgs: [form['id']],
    );
  }

  Future<int> deleteForm(int id) async {
    final Database database = await getDatabase();
    return await database.delete(
      'forms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
