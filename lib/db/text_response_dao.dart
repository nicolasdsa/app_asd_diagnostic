import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:flutter/material.dart';

class TextResponseDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'form_id INTEGER, '
      'question_id INTEGER, '
      'response_text TEXT, '
      'FOREIGN KEY (form_id) REFERENCES forms(id))';

  static const String _tableName = 'text_responses';

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertResponse(Map<String, dynamic> response) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, response);
  }

  Future<List<Question>> getResponsesForForm(int formId) async {
    final db = await dbHelper.database;

    final questions = await db.rawQuery('''
      SELECT $_tableName.response_text, questions.question, questions.id
      FROM $_tableName
      INNER JOIN questions ON $_tableName.question_id = questions.id
      WHERE $_tableName.form_id = ?
    ''', [formId]);
    return toList(questions);
  }

  Future<List<Map<String, dynamic>>> getQuestionsForForm(int formId) async {
    final db = await dbHelper.database;
    final questionDao = QuestionDao();

    // Obtém as respostas de texto para o formulário
    final textResponses = await db.query(
      _tableName,
      where: 'form_id = ?',
      whereArgs: [formId],
    );

    // Para cada resposta de texto, busca a questão correspondente
    final List<Map<String, dynamic>> result = [];
    for (var response in textResponses) {
      final question = await questionDao.getOne(response['question_id'] as int);
      result.add({
        "question_text": question.name,
        "response_text": response['response_text'],
      });
    }

    return result;
  }

  Future<List<Question>> toList(List<Map<String, dynamic>> questionsAll) async {
    final List<Question> questions = [];
    for (Map<String, dynamic> linha in questionsAll) {
      final Question question = Question(
        linha["id"],
        linha["question"],
        null,
        true,
        ValueNotifier<String?>(null), // Inicializa o ValueNotifier
        TextEditingController(),
        null,
        ValueNotifier<String?>(null),
        initialAnswer: linha["response_text"],
      );
      questions.add(question);
    }
    return questions;
  }
}
