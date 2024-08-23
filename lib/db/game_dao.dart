import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';

class GameDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'link TEXT, '
      'name TEXT)';

  static const String _tableName = 'games';
  static const String _name = 'name';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllHash() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      columns: ['id', 'name', 'link'],
    );
    return result;
  }

  Future<List<GameComponent>> toList(
      List<Map<String, dynamic>> gamesAll) async {
    final List<GameComponent> games = [];
    for (Map<String, dynamic> linha in gamesAll) {
      final GameComponent game =
          GameComponent(linha[_name], linha['link'], id: linha[_id]);
      games.add(game);
    }
    return games;
  }
}
