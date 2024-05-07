import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
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

  String _name = 'Perguntas';
  String _selectedName = '';

  void _handleCardOptionTap(String name) {
    setState(() {
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            if (_selectedName.isNotEmpty) ...[
              AnimatedOpacity(
                opacity: _typeFormElements.isEmpty ? 0.0 : 1.0,
                duration: const Duration(seconds: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var element in _typeFormElements)
                      Text('${element['name']}'),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CardOption('Perguntas', Icons.help,
                          onTap: _handleCardOptionTap),
                      const SizedBox(width: 8),
                      CardOption('Jogos', Icons.games,
                          onTap: _handleCardOptionTap),
                      const SizedBox(width: 8),
                      CardOption('Sons', Icons.volume_up,
                          onTap: _handleCardOptionTap),
                      const SizedBox(width: 8),
                      CardOption('Dados', Icons.data_usage,
                          onTap: _handleCardOptionTap),
                    ],
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: [
                      if (_name == 'Perguntas') ...[
                        ValueListenableBuilder(
                          valueListenable: questionChangeNotifier,
                          builder: (context, value, child) {
                            return FutureBuilder<List<Question>>(
                              future: QuestionDao().getAll(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final items = snapshot.data;
                                  return Column(
                                    children:
                                        items?.map((item) => item).toList() ??
                                            [],
                                  );
                                }
                              },
                            );
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuestionCreateScreen(
                                      questionChangeNotifier:
                                          questionChangeNotifier)),
                            );
                          },
                          child: Text('Add Question'),
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
                    ],
                  ),
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
                    child: const Text('Submit'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
