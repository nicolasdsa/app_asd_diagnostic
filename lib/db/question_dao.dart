import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
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

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await dbHelper.database;
    return await db
        .query(_tableName); // Retorna o resultado da consulta diretamente
  }

  Future<List<Question>> toList(List<Map<String, dynamic>> questionsAll) async {
    final List<Question> questions = [];
    for (Map<String, dynamic> linha in questionsAll) {
      final nameTypeQuestion =
          await TypeQuestionDao().getTypeQuestionName(linha[_idType]);
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
        nameTypeQuestion,
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
    final nameTypeQuestion =
        await TypeQuestionDao().getTypeQuestionName(result[0][_idType]);
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
      nameTypeQuestion,
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
