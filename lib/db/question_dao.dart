import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:flutter/material.dart';

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

  Future<bool> checkQuestionIsInForm(int id) async {
    final db = await dbHelper.database;

    final textResponseResult = await db.query(
      'text_responses',
      where: 'question_id = ?',
      whereArgs: [id],
    );
    if (textResponseResult.isNotEmpty) {
      return true;
    }

    final optionResponseResult = await db.query(
      'option_responses',
      where: 'question_id = ?',
      whereArgs: [id],
    );
    if (optionResponseResult.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<bool> deleteQuestionById(int id) async {
    final db = await dbHelper.database;

    final textResponseResult = await db.query(
      'text_responses',
      where: 'question_id = ?',
      whereArgs: [id],
    );
    if (textResponseResult.isNotEmpty) {
      return false;
    }

    final optionResponseResult = await db.query(
      'option_responses',
      where: 'question_id = ?',
      whereArgs: [id],
    );
    if (optionResponseResult.isNotEmpty) {
      return false;
    }

    // Excluir as opções de resposta da questão
    await db.delete(
      'answer_options',
      where: 'id_question = ?',
      whereArgs: [id],
    );
    // Excluir a questão
    await db.delete(
      _tableName,
      where: '$_id = ?',
      whereArgs: [id],
    );

    return true;
  }

  Future<int> editSimpleQuestionById(int id, String question) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      {'question': question},
      where: '$_id = ?',
      whereArgs: [id],
    );
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

  Future<void> updateMultipleOptionsQuestion(
      int questionId, String newQuestionText, List<String> newOptions) async {
    final db = await dbHelper.database;

    // Atualizar o texto da pergunta
    await db.update(
      _tableName,
      {'question': newQuestionText},
      where: 'id = ?',
      whereArgs: [questionId],
    );

    // Excluir as opções de resposta antigas
    await db.delete(
      'answer_options',
      where: 'id_question = ?',
      whereArgs: [questionId],
    );

    // Inserir as novas opções de resposta
    for (String option in newOptions) {
      await db.insert(
        'answer_options',
        {
          'id_question': questionId,
          'option_text': option,
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query(_tableName);

    final List<Map<String, dynamic>> resultAnswer = [];

    for (Map<String, dynamic> question in result) {
      final resultQuestion = Map<String, dynamic>.from(question);

      if (resultQuestion[_idType] == 2) {
        final answerOptionsAndId =
            await AnswerOptionsDao().getOptionsForQuestion(resultQuestion[_id]);

        final answerOptions = answerOptionsAndId
            .map((option) => option['option_text'] as String)
            .toList();

        final answerOptionIds = answerOptionsAndId
            .map((option) => option['id'].toString())
            .toList();

        resultQuestion['answerOptions'] = answerOptions;
        resultQuestion['answerOptionIds'] = answerOptionIds;
      } else {
        resultQuestion['answerOptions'] = null;
      }

      resultAnswer.add(resultQuestion);
    }
    return resultAnswer;
  }

  Future<List<Question>> toList(List<Map<String, dynamic>> questionsAll) async {
    final List<Question> questions = [];
    for (Map<String, dynamic> linha in questionsAll) {
      List<Map<String, dynamic>>? answerOptionsAndId;

      List<String>? answerOptions;
      List<String>? answerOptionIds;

      if (linha[_idType] == 2) {
        answerOptionsAndId =
            await AnswerOptionsDao().getOptionsForQuestion(linha[_id]);

        answerOptions = answerOptionsAndId
            .map((option) => option['option_text'] as String)
            .toList();

        answerOptionIds = answerOptionsAndId
            .map((option) => option['id'].toString())
            .toList();
      }
      final Question question = Question(
        linha[_id],
        linha[_question],
        answerOptions,
        false,
        ValueNotifier<String?>(null), // Inicializa o ValueNotifier
        TextEditingController(),
        answerOptionIds,
        ValueNotifier<String?>(null), // Inicializa o ValueNotifier
      );
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

    List<Map<String, dynamic>>? answerOptionsAndId;
    List<String>? answerOptions;
    List<String>? answerOptionIds;

    if (result[0][_idType] == 2) {
      answerOptionsAndId =
          await AnswerOptionsDao().getOptionsForQuestion(result[0][_id]);

      answerOptions = answerOptionsAndId
          .map((option) => option['option_text'] as String)
          .toList();

      answerOptionIds =
          answerOptionsAndId.map((option) => option['id'].toString()).toList();
    }
    final Question question = Question(
      result[0][_id],
      result[0][_question],
      answerOptions,
      true,
      ValueNotifier<String?>(null), // Inicializa o ValueNotifier
      TextEditingController(),
      answerOptionIds,
      ValueNotifier<String?>(null), // Inicializa o ValueNotifier
    );
    return question;
  }
}
