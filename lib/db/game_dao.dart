import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';

class GameDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'link TEXT, '
      'name TEXT)';

  static const String _tableName = 'games';
  static const String _name = 'name';

  final dbHelper = DatabaseHelper.instance;

  Future<List<GameComponent>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<GameComponent> games = await toList(result);
    return games;
  }

  Future<List<GameComponent>> toList(
      List<Map<String, dynamic>> gamesAll) async {
    final List<GameComponent> games = [];
    for (Map<String, dynamic> linha in gamesAll) {
      final GameComponent game = GameComponent(linha[_name], linha['link']);
      games.add(game);
    }
    return games;
  }
}