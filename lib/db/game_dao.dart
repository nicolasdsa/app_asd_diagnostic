import 'package:app_asd_diagnostic/db/database.dart';

class GameDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'link TEXT, '
      'short_description TEXT, '
      'long_description TEXT, '
      'path TEXT, '
      'name TEXT, '
      'config TEXT)';

  static const String _tableName = 'games';
  static const String _name = 'name';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result;
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    throw Exception('No result found');
  }

  Future<List<Map<String, dynamic>>> getAllHash() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      columns: ['id', 'name', 'link'],
    );
    return result;
  }

  Future<Map<String, dynamic>> getAllGamesWithObjectives(String gameId) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> objectivesResult = await db.query(
      'objectives',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    final List objectives =
        objectivesResult.map((obj) => obj['objective']).toList();

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [gameId],
    );

    final Map<String, dynamic> game = Map<String, dynamic>.from(result.first);

    game['objectives'] = objectives;

    return game;
  }
}
