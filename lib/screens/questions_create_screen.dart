import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:flutter/material.dart';

class QuestionCreateScreen extends StatefulWidget {
  QuestionCreateScreen();

  @override
  _QuestionsCreateScreenState createState() => _QuestionsCreateScreenState();
}

class _QuestionsCreateScreenState extends State<QuestionCreateScreen> {
  final _questionDao = QuestionDao();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  List<Map<String, dynamic>> _typeQuestions = [];
  int _selectedId = 0;

  @override
  void initState() {
    super.initState();
    _getTypeQuestions();
  }

  void _getTypeQuestions() async {
    _typeQuestions = await TypeQuestionDao().getAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Pergunta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              if (_selectedId == 1) ...[
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
                  child: const Text('Adicionar pergunta'),
                  onPressed: () {
                    var questionText = _nameController.text;
                    _questionDao.insertSimpleQuestion(
                        {"question": questionText, "id_type": _selectedId});
                    Navigator.of(context).pop();
                  },
                )
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
                  child: const Text('Adicionar pergunta'),
                  onPressed: () {
                    var questionText = _nameController.text;
                    var options = _optionControllers
                        .map((controller) => controller.text)
                        .toList();
                    _questionDao.insertMultipleOptionsQuestion(
                        questionText, options, _selectedId);
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
