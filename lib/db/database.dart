import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'test.db');
  return openDatabase(path,
      onCreate: (db, version) => db.execute(FormDao.tableSql), version: 1);
}
