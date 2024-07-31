import 'package:app_asd_diagnostic/screens/questions_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';
import 'package:app_asd_diagnostic/screens/components/list_data.dart';
import 'package:app_asd_diagnostic/screens/components/patient_search_field.dart';
import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/screens/components/json_data_chart.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/display_elements_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class FormScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  FormScreen({Key? key, required this.formChangeNotifier}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late ValueNotifier<int> questionChangeNotifier;
  final _formKey = GlobalKey<FormState>();
  final _typeFormDao = TypeFormDao();
  final _hashAccessDao = HashAccessDao();
  List<Map<String, dynamic>> _typeFormElements = [];

  String _name = '';
  String _selectedTypeForm = '';
  String _selectedPatientId = '';

  List<List<dynamic>> _analiseInfoElements = [];
  List<List<dynamic>> _avaliarComportamentoElements = [];

  @override
  void initState() {
    super.initState();
    questionChangeNotifier = ValueNotifier(0);
  }

  void handleExpansionChange(
      String? game, DateTime? initialDate, DateTime? endDate, bool addList) {
    bool existsBeforeRemoval = _analiseInfoElements
        .any((element) => element[0] == 'json_data' && element[1] == game);

    if (addList) {
      _analiseInfoElements.removeWhere(
          (element) => element[0] == 'json_data' && element[1] == game);
    }

    if (existsBeforeRemoval && !addList) {
      _analiseInfoElements.removeWhere(
          (element) => element[0] == 'json_data' && element[1] == game);

      _analiseInfoElements.add(['json_data', game, initialDate, endDate]);
    }

    if (!existsBeforeRemoval && addList) {
      _analiseInfoElements.add(['json_data', game, initialDate, endDate]);
    }

    print('Estado atual de _analiseInfoElements: $_analiseInfoElements');
  }

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

  void _addElementToAnaliseInfo(String tableName, dynamic id) {
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

  Future<void> _createSession() async {
    // Pega o ID do paciente
    final patientId = _selectedPatientId;
    // Pega os IDs dos jogos
    final gameIds =
        _avaliarComportamentoElements.map((element) => element[1]).join(',');

    // Cria o hash
    final hashInput = '$patientId-$gameIds';
    final bytes = utf8.encode(hashInput);
    final hash = sha256.convert(bytes).toString();

    // Imprime o hash no console
    print('Hash gerado: $hash');

    // Salva no banco de dados
    final hashAccess = {
      'id_patient': patientId,
      'accessHash': hash,
      'gameLinks': hashInput,
    };
    await _hashAccessDao.insert(hashAccess);

    // Mostra uma mensagem de sucesso
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sessão criada com sucesso! Hash: $hash')),
      );
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
              PatientSearchField(
                onPatientSelected: (int patientId) {
                  setState(() {
                    _selectedPatientId = patientId.toString();
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
              if (_selectedPatientId.isNotEmpty &&
                  _typeFormElements.isNotEmpty) ...[
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
                  ),
                ),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_selectedTypeForm.isNotEmpty &&
                        _selectedPatientId.isNotEmpty &&
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
                        _selectedPatientId.isNotEmpty &&
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
                        questionChangeNotifier: null,
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
                      // Código para exibir sons
                    ],
                    if (_name == 'Dados') ...[
                      GestureDetector(
                          onTap: () {
                            //_addElementToAnaliseInfo(
                            //  'json_data', CombinedLineChart());
                          },
                          child: CombinedLineChart(
                              idPatient: int.parse(_selectedPatientId),
                              onExpansionChange: handleExpansionChange)),
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
                    if (_selectedTypeForm == 'Analise de informações') ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayElementsScreen(
                                  elements: _analiseInfoElements,
                                  idPatient: int.parse(_selectedPatientId)),
                            ),
                          );
                        },
                        child: const Text('Ver Elementos Analisados'),
                      ),
                    ] else if (_selectedTypeForm ==
                        'Avaliar Comportamento') ...[
                      ElevatedButton(
                        onPressed: _createSession,
                        child: const Text('Criar Sessão'),
                      ),
                    ],
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
