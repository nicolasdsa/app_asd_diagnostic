class ObjectiveDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'game_id INTEGER, '
      'objective TEXT, '
      'FOREIGN KEY(game_id) REFERENCES games(id) ON DELETE CASCADE)';

  static const String _tableName = 'objectives';
}
