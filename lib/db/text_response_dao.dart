import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';

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

  Future<List<Map<String, dynamic>>> getResponsesForForm(int formId) async {
    final db = await dbHelper.database;
    return await db.query(
      _tableName,
      where: 'form_id = ?',
      whereArgs: [formId],
    );
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
}
