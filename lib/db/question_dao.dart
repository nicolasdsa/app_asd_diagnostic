import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';

class QuestionDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'question TEXT, '
      'id_type INTEGER, '
      'FOREIGN KEY (id_type) REFERENCES type_questions(id))';

  static const String _tableName = 'questions';

  static const String _idType = 'id_type';
  static const String _question = 'question';
  static const String _id = 'id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertSimpleQuestion(Map<String, dynamic> form) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, form);
  }

  Future<int> insertMultipleOptionsQuestion(
      String form, List<String> teste, int idType) async {
    final db = await dbHelper.database;
    int newQuestion =
        await db.insert(_tableName, {"question": form, "id_type": idType});

    for (String option in teste) {
      await db.insert('answer_options',
          {"option_text": option, "id_question": newQuestion});
    }

    return newQuestion;
  }

  Future<List<Question>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<Question> questions = await toList(result);
    return questions;
  }

  Future<List<Question>> toList(List<Map<String, dynamic>> questionsAll) async {
    final List<Question> questions = [];
    for (Map<String, dynamic> linha in questionsAll) {
      final nameTypeQuestion =
          await TypeQuestionDao().getTypeQuestionName(linha[_idType]);
      List<String>? answerOptions;
      if (linha[_idType] == 2) {
        answerOptions =
            await AnswerOptionsDao().getOptionsForQuestion(linha[_id]);
      }
      final Question question = Question(
          linha[_id], linha[_question], nameTypeQuestion, answerOptions, false);
      questions.add(question);
    }
    return questions;
  }

  Future<Question> getOne(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'id LIKE ?',
      whereArgs: ['%$id%'],
    );
    final nameTypeQuestion =
        await TypeQuestionDao().getTypeQuestionName(result[0][_idType]);
    List<String>? answerOptions;
    if (result[0][_idType] == 2) {
      answerOptions =
          await AnswerOptionsDao().getOptionsForQuestion(result[0][_id]);
    }
    final Question question = Question(result[0][_id], result[0][_question],
        nameTypeQuestion, answerOptions, true);
    return question;
  }
}
