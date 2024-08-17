import 'package:app_asd_diagnostic/db/database.dart';

class OptionResponseDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'form_id INTEGER, '
      'question_id INTEGER, '
      'option_id INTEGER, '
      'FOREIGN KEY (form_id) REFERENCES forms(id))';

  static const String _tableName = 'option_responses';

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

    // Consulta para buscar todas as perguntas, opções e respostas
    final List<Map<String, dynamic>> queryResult = await db.rawQuery('''
    SELECT 
      q.id AS question_id,
      q.question AS question_text,
      ao.id AS option_id,
      ao.option_text AS option_text,
      opt_res.option_id AS selected_option_id
    FROM 
      questions q
    LEFT JOIN 
      answer_options ao ON q.id = ao.id_question
    LEFT JOIN 
      option_responses opt_res ON q.id = opt_res.question_id AND opt_res.form_id = ?
    WHERE 
      opt_res.form_id = ?
    ORDER BY q.id, ao.id
  ''', [formId, formId]);

    // Processamento dos resultados para estrutura desejada
    Map<int, Map<String, dynamic>> questionsMap = {};

    for (var row in queryResult) {
      int questionId = row['question_id'];
      String questionText = row['question_text'];
      String optionText = row['option_text'];
      int? selectedOptionId = row['selected_option_id'];
      int optionId = row['option_id'];

      if (!questionsMap.containsKey(questionId)) {
        questionsMap[questionId] = {
          'question_text': questionText,
          'options': [],
          'answer': null
        };
      }

      questionsMap[questionId]?['options'].add(optionText);

      if (selectedOptionId != null && selectedOptionId == optionId) {
        questionsMap[questionId]?['answer'] =
            questionsMap[questionId]?['options'].length - 1;
      }
    }

    // Convertendo para lista
    List<Map<String, dynamic>> result = questionsMap.values.toList();

    return result;
  }
}
