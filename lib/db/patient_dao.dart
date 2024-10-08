import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/db/patient_object_hit_run_dao.dart';

class PatientDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT, '
      'age INTEGER, '
      'gender TEXT, '
      'photo TEXT, '
      'description TEXT, '
      'diagnosis TEXT)';

  static const String _tableName = 'patients';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> patient) async {
    final objects = PatientObjectHitRunDao();
    final db = await dbHelper.database;
    final create = await db.insert(_tableName, patient);
    await objects.insert({
      'patient_id': create,
      'hit_run_object_id': 1,
    });
    return create;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result;
  }

  Future<int> update(int id, Map<String, dynamic> patient) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      patient,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> filterByName(String name) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return result;
  }

  Future<Map<String, dynamic>> getPatientById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    final patientData = result.first;

    return patientData;
  }
}
