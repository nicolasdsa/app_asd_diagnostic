class FormQuestionDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'id_form INTEGER, '
      'id_question INTEGER, '
      'FOREIGN KEY (id_form) REFERENCES forms(id), '
      'FOREIGN KEY (id_question) REFERENCES questions(id))';

  static const String _tableName = 'form_questions';
}
