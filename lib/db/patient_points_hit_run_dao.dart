import 'package:app_asd_diagnostic/db/database.dart';

class PatientPointsHitRunDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'patient_id INTEGER, '
      'game_id INTEGER, '
      'points INTEGER, '
      'FOREIGN KEY(game_id) REFERENCES games(id) ON DELETE CASCADE, '
      'FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE)';

  static const String _tableName = 'patient_points_hit_run';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> response) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, response);
  }

  Future<int> update(Map<String, dynamic> response) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      response,
      where: 'patient_id = ?',
      whereArgs: [response['patient_id']],
    );
  }

  Future<Map<String, dynamic>?> getUserBestScore(int gameId, int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(_tableName,
        where: 'game_id = ? AND patient_id = ?',
        whereArgs: [gameId, userId],
        orderBy: 'points DESC',
        limit: 1);
    return result.isNotEmpty ? result.first : null;
  }
}
