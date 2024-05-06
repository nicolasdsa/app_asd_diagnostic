class AnswerOptionsDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'option_text TEXT, '
      'id_question INTEGER, '
      'FOREIGN KEY (id_question) REFERENCES questions(id))';

  static const String _tableName = 'answer_options';
}
