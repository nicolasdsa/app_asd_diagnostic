import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/form_question_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  Future<Database?> get database1 async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(FormDao.tableSql);
    await db.execute(FormQuestionDao.tableSql);
    await db.execute(AnswerOptionsDao.tableSql);
    await db.execute(PatientDao.tableSql);
    await db.execute(TypeQuestionDao.tableSql);
    await db.execute(QuestionDao.tableSql);
  }

  _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }
}
