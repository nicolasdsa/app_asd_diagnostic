import 'package:app_asd_diagnostic/db/database.dart';

class PatientObjectHitRunDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'patient_id INTEGER,'
      'hit_run_object_id INTEGER,'
      'FOREIGN KEY(patient_id) REFERENCES patients(id),'
      'FOREIGN KEY(hit_run_object_id) REFERENCES hit_run_objects(id))';

  static const String _tableName = 'patient_object_hit_run';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> patientObject) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, patientObject);
  }

  Future<Map<String, dynamic>> getOne(int objectId, int patientId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tableName,
      where: 'hit_run_object_id = ? AND patient_id = ?',
      whereArgs: [objectId, patientId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<Map<String, dynamic>> getObject(int patientId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT hit_run_objects.objects, hit_run_objects.amount FROM $_tableName
      INNER JOIN hit_run_objects ON $_tableName.hit_run_object_id = hit_run_objects.id
      WHERE $_tableName.patient_id = $patientId
    ''');
    return result.first;
  }

  Future<int> update(int id, Map<String, dynamic> patient) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      patient,
      where: 'patient_id = ?',
      whereArgs: [id],
    );
  }
}
