import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/patient.dart';

class PatientDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT,'
      'age INTEGER,'
      'gender TEXT)';

  static const String _tableName = 'patients';
  static const String _name = 'name';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> form) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, form);
  }

  Future<List<Patient>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<Patient> patients = toList(result);
    return patients;
  }

  Future<int> update(Map<String, dynamic> patient) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      patient,
      where: 'id = ?',
      whereArgs: [patient['id']],
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

  Future<List<String>> filterByName(String name) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    List<String> patientNames =
        result.map((map) => map[_name] as String).toList();
    return patientNames;
  }

  List<Patient> toList(List<Map<String, dynamic>> patientsAll) {
    final List<Patient> patients = [];
    for (Map<String, dynamic> linha in patientsAll) {
      final Patient patient = Patient(linha[_id], linha[_name]);
      patients.add(patient);
    }
    return patients;
  }
}
