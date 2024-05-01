import 'package:app_asd_diagnostic/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FormQuestionDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'id_form INTEGER, '
      'id_question INTEGER, '
      'FOREIGN KEY (id_form) REFERENCES forms(id), '
      'FOREIGN KEY (id_question) REFERENCES questions(id))';

  static const String _tableName = 'form_questions';
}
