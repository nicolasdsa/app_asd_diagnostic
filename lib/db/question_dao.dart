import 'package:app_asd_diagnostic/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuestionDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'question TEXT, '
      'id_type INTEGER, '
      'FOREIGN KEY (id_type) REFERENCES type_questions(id))';

  static const String _tableName = 'questions';
}
