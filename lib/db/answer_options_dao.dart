import 'package:app_asd_diagnostic/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnswerOptionsDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'option_text TEXT, '
      'id_question INTEGER, '
      'FOREIGN KEY (id_question) REFERENCES questions(id))';

  static const String _tableName = 'answer_options';
}
