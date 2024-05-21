import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/screens/components/list_data.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/questions_create_screen.dart';
import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  FormScreen({required this.formChangeNotifier});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late ValueNotifier<int> questionChangeNotifier;

  @override
  void initState() {
    super.initState();
    questionChangeNotifier = ValueNotifier(0);
  }

  final _formKey = GlobalKey<FormState>();
  final _formDao = FormDao();
  final _patientDao = PatientDao();
  final _typeFormDao = TypeFormDao();
  List<Map<String, dynamic>> _typeFormElements = [];

  String _name = '';
  String _selectedName = '';
  String _selectedTypeForm = '';

  void _handleCardOptionTap(String name) {
    setState(() {
      _name = name;
    });
  }

  void _handleTypeFormTap(String name) {
    setState(() {
      _selectedTypeForm = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Data'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _patientDao.filterByName(textEditingValue.text);
                },
                onSelected: (String selection) {
                  setState(() {
                    _selectedName = selection;
                    _typeFormElements = [];
                  });
                  _typeFormDao
                      .getAll()
                      .then((List<Map<String, dynamic>> elements) {
                    setState(() {
                      _typeFormElements = elements;
                    });
                  });
                },
              ),
              if (_selectedName.isNotEmpty && _typeFormElements.isNotEmpty) ...[
                AnimatedOpacity(
                    opacity: _typeFormElements.isEmpty ? 0.0 : 1.0,
                    duration: const Duration(seconds: 3),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CardOption(
                              _typeFormElements[0]['name'], Icons.analytics,
                              onTap: _handleTypeFormTap),
                          const SizedBox(width: 8),
                          CardOption(
                              _typeFormElements[1]['name'], Icons.psychology,
                              onTap: _handleTypeFormTap)
                        ],
                      ),
                    )),
              ],
              Form(
                child: Column(
                  children: [
                    if (_selectedTypeForm.isNotEmpty &&
                        _selectedName.isNotEmpty &&
                        _selectedTypeForm == 'Analise de informações') ...[
                      Row(
                        children: [
                          // Add your widgets here
                          CardOption('Perguntas', Icons.help,
                              onTap: _handleCardOptionTap),
                          const SizedBox(width: 8),
                          CardOption('Sons', Icons.volume_up,
                              onTap: _handleCardOptionTap),
                          const SizedBox(width: 8),
                          CardOption('Dados', Icons.data_usage,
                              onTap: _handleCardOptionTap),
                        ],
                      ),
                    ],
                    if (_selectedTypeForm.isNotEmpty &&
                        _selectedName.isNotEmpty &&
                        _selectedTypeForm == 'Avaliar Comportamento') ...[
                      Row(
                        children: [
                          CardOption('Jogos', Icons.games,
                              onTap: _handleCardOptionTap),
                        ],
                      ),
                    ],
                    if (_name == 'Jogos') ...[
                      // Code for displaying games
                    ],
                    if (_name == 'Sons') ...[
                      // Code for displaying sounds
                    ],
                    if (_name == 'Dados') ...[
                      // Code for displaying data
                    ],
                    if (_name == 'Perguntas') ...[
                      ListData<Question>(
                        questionChangeNotifier: questionChangeNotifier,
                        getItems: () => QuestionDao().getAll(),
                        buildItem: (item) => item,
                        navigateTo: (context) => QuestionCreateScreen(
                          questionChangeNotifier: questionChangeNotifier,
                        ),
                        buttonText: 'Adicionar pergunta',
                      )
                    ],
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _formDao.insertForm({
                            'name': _name,
                          });
                          widget.formChangeNotifier.value++;
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      child: const Text('Criar formulário'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
