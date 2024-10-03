import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:flutter/material.dart';

class QuestionCreateScreen extends StatefulWidget {
  final int? questionId; // Novo parâmetro opcional para edição
  final ValueNotifier<List<Map<String, dynamic>>>? notifier;

  const QuestionCreateScreen(
      {super.key, this.questionId, this.notifier}); // Construtor modificado

  @override
  QuestionsCreateScreenState createState() => QuestionsCreateScreenState();
}

class QuestionsCreateScreenState extends State<QuestionCreateScreen> {
  final _questionDao = QuestionDao();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  List<Map<String, dynamic>> _typeQuestions = [];
  int _selectedId = 1;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _getTypeQuestions();
    if (widget.questionId != null) {
      _loadQuestionData(
          widget.questionId!); // Carregar dados da questão se for edição
    }
  }

  void _getTypeQuestions() async {
    _typeQuestions = await TypeQuestionDao().getAll();
    setState(() {});
  }

  void _loadQuestionData(int questionId) async {
    final question = await _questionDao.getOne(questionId);
    _nameController.text = question.name;
    _isEditing = true; // Indicamos que estamos no modo de edição
    if (question.answerOptions != null) {
      _optionControllers.clear();
      for (String option in question.answerOptions!) {
        _optionControllers.add(TextEditingController(text: option));
      }
    }
    _selectedId = question.answerOptions != null ? 2 : 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Pergunta' : 'Cadastro de Pergunta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isEditing) // Mostrar o cabeçalho de tipo de questão apenas na criação
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(_typeQuestions[0]['name']),
                          onTap: () {
                            setState(() {
                              _selectedId = _typeQuestions[0]['id'];
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(_typeQuestions[1]['name']),
                          onTap: () {
                            setState(() {
                              _selectedId = _typeQuestions[1]['id'];
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              if (_selectedId == 1 ||
                  _isEditing && _optionControllers.isEmpty) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Pergunta'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Escreva a pergunta';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  child: Text(
                      _isEditing ? 'Atualizar pergunta' : 'Adicionar pergunta'),
                  onPressed: () async {
                    var questionText = _nameController.text;
                    if (_isEditing) {
                      await _questionDao.editSimpleQuestionById(
                        widget.questionId!,
                        questionText,
                      );
                      // Atualize o notifier com a nova pergunta editada
                      if (widget.notifier != null) {
                        var questions = widget.notifier!.value;
                        int index = questions
                            .indexWhere((q) => q['id'] == widget.questionId);
                        if (index != -1) {
                          questions[index]['question'] = questionText;
                          widget.notifier!.value = [...questions];
                        }
                      }
                    } else {
                      int newQuestionId =
                          await _questionDao.insertSimpleQuestion({
                        "question": questionText,
                        "id_type": _selectedId,
                      });
                      // Adicione a nova pergunta ao notifier
                      if (widget.notifier != null) {
                        var questions = widget.notifier!.value;
                        questions.add({
                          'id': newQuestionId,
                          'question': questionText,
                          'id_type': _selectedId,
                        });
                        widget.notifier!.value = [...questions];
                      }
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
              if (_selectedId == 2) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Pergunta'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Escreva a pergunta';
                    }
                    return null;
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _optionControllers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: TextFormField(
                          controller: _optionControllers[index],
                          decoration:
                              InputDecoration(labelText: 'Opção ${index + 1}'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Escreva a opção de resposta';
                            }
                            return null;
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              _optionControllers.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  child: const Text('Adicionar opção'),
                  onPressed: () {
                    setState(() {
                      _optionControllers.add(TextEditingController());
                    });
                  },
                ),
                ElevatedButton(
                  child: Text(
                      _isEditing ? 'Atualizar pergunta' : 'Adicionar pergunta'),
                  onPressed: () async {
                    var questionText = _nameController.text;
                    var options = _optionControllers
                        .map((controller) => controller.text)
                        .toList();
                    if (_isEditing) {
                      await _questionDao.updateMultipleOptionsQuestion(
                        widget.questionId!,
                        questionText,
                        options,
                      );
                      // Atualize o notifier com a pergunta de múltiplas opções editada
                      if (widget.notifier != null) {
                        var questions = widget.notifier!.value;
                        int index = questions
                            .indexWhere((q) => q['id'] == widget.questionId);
                        if (index != -1) {
                          questions[index]['question'] = questionText;
                          questions[index]['answerOptions'] = options;
                          widget.notifier!.value = [...questions];
                        }
                      }
                    } else {
                      int newQuestionId =
                          await _questionDao.insertMultipleOptionsQuestion(
                        questionText,
                        options,
                        _selectedId,
                      );
                      // Adicione a nova pergunta ao notifier
                      if (widget.notifier != null) {
                        var questions = widget.notifier!.value;
                        questions.add({
                          'id': newQuestionId,
                          'question': questionText,
                          'id_type': _selectedId,
                          'answerOptions': options,
                        });
                        widget.notifier!.value = [...questions];
                      }
                    }

                    Navigator.of(context).pop();
                  },
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
