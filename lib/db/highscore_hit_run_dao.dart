import 'package:app_asd_diagnostic/db/database.dart';

class HighScoreHitRunDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'game_id INTEGER, '
      'name TEXT, '
      'points INTEGER, '
      'FOREIGN KEY(game_id) REFERENCES games(id) ON DELETE CASCADE)';

  static const String _tableName = 'highscore_hit_run';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Map<String, dynamic> response) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, response);
  }

  Future<List<Map<String, dynamic>>> getTopScores(int gameId) async {
    final db = await dbHelper.database;
    return await db.query(_tableName,
        where: 'game_id = ?',
        whereArgs: [gameId],
        orderBy: 'points DESC',
        limit: 10);
  }
}
