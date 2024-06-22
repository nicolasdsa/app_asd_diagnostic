import 'dart:convert';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';
import 'package:app_asd_diagnostic/screens/components/list_data.dart';
import 'package:app_asd_diagnostic/screens/questions_create_screen.dart';

class FormScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  FormScreen({required this.formChangeNotifier});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late ValueNotifier<int> questionChangeNotifier;
  final Set<GameComponent> _selectedGames = Set<GameComponent>();

  @override
  void initState() {
    super.initState();
    questionChangeNotifier = ValueNotifier(0);
  }

  final _formKey = GlobalKey<FormState>();
  final _formDao = HashAccessDao();
  final _patientDao = PatientDao();
  final _typeFormDao = TypeFormDao();
  List<Map<String, dynamic>> _typeFormElements = [];

  String _name = '';
  String _selectedName = '';
  String _selectedTypeForm = '';
  String _selectedPatientId = ''; // Add this line

  List<List<dynamic>> _analiseInfoElements = [];
  List<List<dynamic>> _avaliarComportamentoElements = [];

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

  void _addElementToAnaliseInfo(String tableName, int id) {
    final newElement = [tableName, id];
    setState(() {
      if (_analiseInfoElements
          .any((element) => listEquals(element, newElement))) {
        _analiseInfoElements.removeWhere((element) => element[1] == id);
        print(
            'Elemento removido de _analiseInfoElements: $_analiseInfoElements');
      } else {
        _analiseInfoElements.add(newElement);
        print(
            'Novo elemento adicionado em _analiseInfoElements: $_analiseInfoElements');
      }
    });
  }

  void _addElementToAvaliarComportamento(String tableName, int id) {
    final newElement = [tableName, id];
    setState(() {
      if (_avaliarComportamentoElements
          .any((element) => listEquals(element, newElement))) {
        _avaliarComportamentoElements
            .removeWhere((element) => element[1] == id);
        print(
            'Elemento removido de _avaliarComportamentoElements: $_avaliarComportamentoElements');
      } else {
        _avaliarComportamentoElements.add(newElement);
        print(
            'Novo elemento adicionado em _avaliarComportamentoElements: $_avaliarComportamentoElements');
      }
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
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  final patients =
                      await _patientDao.filterByName(textEditingValue.text);
                  return patients.map((patient) => patient['name'] as String);
                },
                onSelected: (String selection) async {
                  setState(() {
                    _selectedName = selection;
                    _typeFormElements = [];
                  });
                  final patients =
                      await _patientDao.filterByName(_selectedName);
                  if (patients.isNotEmpty) {
                    _selectedPatientId = patients.first['id'].toString();
                  }
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
                              onTap: (name) => _handleTypeFormTap(name)),
                          const SizedBox(width: 8),
                          CardOption(
                              _typeFormElements[1]['name'], Icons.psychology,
                              onTap: (name) => _handleTypeFormTap(name))
                        ],
                      ),
                    )),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_selectedTypeForm.isNotEmpty &&
                        _selectedName.isNotEmpty &&
                        _selectedTypeForm == 'Analise de informações') ...[
                      Row(
                        children: [
                          CardOption('Perguntas', Icons.help,
                              onTap: (name) => _handleCardOptionTap(name)),
                          const SizedBox(width: 8),
                          CardOption('Sons', Icons.volume_up,
                              onTap: (name) => _handleCardOptionTap(name)),
                          const SizedBox(width: 8),
                          CardOption('Dados', Icons.data_usage,
                              onTap: (name) => _handleCardOptionTap(name)),
                        ],
                      ),
                    ],
                    if (_selectedTypeForm.isNotEmpty &&
                        _selectedName.isNotEmpty &&
                        _selectedTypeForm == 'Avaliar Comportamento') ...[
                      Row(
                        children: [
                          CardOption('Jogos', Icons.games,
                              onTap: (name) => _handleCardOptionTap(name)),
                        ],
                      ),
                    ],
                    if (_name == 'Jogos') ...[
                      ListData<GameComponent>(
                        questionChangeNotifier: questionChangeNotifier,
                        getItems: () => GameDao().getAll(),
                        buildItem: (item) {
                          return GestureDetector(
                            onTap: () {
                              _addElementToAvaliarComportamento(
                                  'games', item.id);
                            },
                            child: item,
                          );
                        },
                      ),
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
                        buildItem: (item) {
                          return GestureDetector(
                            onTap: () {
                              _addElementToAnaliseInfo('questions', item.id);
                            },
                            child: item,
                          );
                        },
                        navigateTo: (context) => QuestionCreateScreen(
                          questionChangeNotifier: questionChangeNotifier,
                        ),
                        buttonText: 'Adicionar pergunta',
                      ),
                    ],
                    ElevatedButton(
                      onPressed: _createForm,
                      child: const Text('Criar formulário'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateAccessHash(String patientId, List<String> gameLinks) {
    final data = json.encode({'patientId': patientId, 'gameLinks': gameLinks});
    return sha256.convert(utf8.encode(data)).toString();
  }

  void _createForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final patientId = _selectedPatientId; // Use _selectedPatientId here
      final gameLinks = _selectedGames.map((game) => game.link).toList();
      print(gameLinks);
      final accessHash = _generateAccessHash(patientId, gameLinks);
      print(accessHash);
      _formDao.insertForm({
        'id_patient': patientId,
        'accessHash': accessHash,
        'gameLinks':
            json.encode(gameLinks), // Salve os links dos jogos como JSON
      });
      widget.formChangeNotifier.value++;
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
