import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/patient.dart';
import 'package:app_asd_diagnostic/screens/components/patient_details.dart';

class PatientDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT, '
      'age INTEGER, '
      'gender TEXT, '
      'photo TEXT, ' // Campo para o caminho da foto
      'description TEXT, ' // Campo para a descrição
      'diagnosis TEXT)'; // Campo para o diagnóstico

  static const String _tableName = 'patients';
  static const String _name = 'name';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> patient) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, patient);
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
