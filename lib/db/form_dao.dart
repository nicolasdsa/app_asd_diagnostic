import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';

class FormDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'id_patient INTEGER, '
      'name TEXT,'
      'created_at TIMESTAMP, '
      'FOREIGN KEY (id_patient) REFERENCES patients(id))';

  static const String _tableName = 'forms';
  static const String _name = 'name';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertForm(Map<String, dynamic> form) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, form);
  }

  Future<List<FormUser>> getAllForms() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result
        .map((row) => FormUser(
            id: row[_id], name: row[_name], createdAt: row['created_at']))
        .toList();
  }

  Future<FormUser> getForm(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result
        .map((row) => FormUser(
            id: row[_id], name: row[_name], createdAt: row['created_at']))
        .first;
  }

  Future<List<FormUser>> getFormsByPatientId(int patientId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id_patient = ?',
      whereArgs: [patientId],
    );

    final forms = result
        .map((row) => FormUser(
            id: row[_id], name: row[_name], createdAt: row['created_at']))
        .toList();

    return forms;
  }
}
