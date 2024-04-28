import 'package:app_asd_diagnostic/db/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PatientDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT)'
      'age INTEGER)'
      'gender TEXT)';

  static const String _tableName = 'patients';
}
