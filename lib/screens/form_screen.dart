import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/screens/components/chart_display.dart';
import 'package:app_asd_diagnostic/screens/components/questions.dart';
import 'package:app_asd_diagnostic/screens/components/sounds.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';
import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/screens/display_elements_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class FormScreen extends StatefulWidget {
  final int idPatient;

  const FormScreen({Key? key, required this.idPatient}) : super(key: key);

  @override
  FormScreenState createState() => FormScreenState();
}

class FormScreenState extends State<FormScreen> with WidgetsBindingObserver {
  ValueNotifier<String?> _currentPlayingSound = ValueNotifier<String?>(null);
  final _formKey = GlobalKey<FormState>();
  final _typeFormDao = TypeFormDao();
  final _hashAccessDao = HashAccessDao();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _typeFormElements = [];
  String _name = '';
  String _selectedTypeForm = '';
  final List<List<dynamic>> _analiseInfoElements = [];
  final List<List<dynamic>> _avaliarComportamentoElements = [];
  final JsonDataDao jsonDataDao = JsonDataDao();
  late Future<Map<String, List<List<dynamic>>>> futureJsonData;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGame;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _audioPlayer.stop();
    }
  }

  void _pickStartDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null && (endDate == null || date.isBefore(endDate!))) {
      setState(() {
        startDate = date;

        futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
            widget.idPatient, startDate!, endDate!);
        handleExpansionChange(selectedGame, startDate, endDate, false);
      });
    }
  }

  void _pickEndDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null && (startDate == null || date.isAfter(startDate!))) {
      setState(() {
        endDate = date;
        futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
            widget.idPatient, startDate!, endDate!);
        handleExpansionChange(selectedGame, startDate, endDate, false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(const Duration(days: 30));
    endDate = DateTime.now();

    _typeFormDao.getAll().then((List<Map<String, dynamic>> elements) {
      setState(() {
        _typeFormElements = elements;
      });
    });
    futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
        widget.idPatient, startDate!, endDate!);
    WidgetsBinding.instance
        .addObserver(this); // Adiciona o observador do ciclo de vida
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
    if (_analiseInfoElements
        .any((element) => listEquals(element, newElement))) {
      _analiseInfoElements.removeWhere((element) => element[1] == id);
      print('Elemento removido de _analiseInfoElements: $_analiseInfoElements');
    } else {
      _analiseInfoElements.add(newElement);
      print(
          'Novo elemento adicionado em _analiseInfoElements: $_analiseInfoElements');
    }
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
    final patientId = widget.idPatient;
    // Pega os IDs dos jogos
    final gameIds = _avaliarComportamentoElements.isNotEmpty
        ? _avaliarComportamentoElements.map((element) => element[1]).join(',')
        : '';

    // Cria o hash
    final hashInput = '$patientId-$gameIds';
    final bytes = utf8.encode(hashInput);
    final hash = sha256.convert(bytes).toString();

    print('Hash gerado: $hash');

    // Salva no banco de dados
    final hashAccess = {
      'id_patient': patientId,
      'accessHash': hash,
      'gameLinks': hashInput,
    };
    await _hashAccessDao.insert(hashAccess);
    await Clipboard.setData(ClipboardData(text: hash));

    // Mostra uma mensagem de sucesso
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sessão criada com sucesso! Hash: $hash')),
      );
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
        child: ListView(
          shrinkWrap: true,
          children: [
            if (_typeFormElements.isNotEmpty) ...[
              AnimatedOpacity(
                opacity: _typeFormElements.isEmpty ? 0.0 : 1.0,
                duration: const Duration(seconds: 3),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CardOption(_typeFormElements[0]['name'], Icons.analytics,
                          onTap: (name) => _handleTypeFormTap(name)),
                      const SizedBox(width: 8),
                      CardOption(_typeFormElements[1]['name'], Icons.psychology,
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
                      _selectedTypeForm == 'Analise de informações') ...[
                    Row(
                      children: [
                        CardOption('Perguntas', Icons.help, onTap: (name) {
                          _handleCardOptionTap(name);
                        }),
                        const SizedBox(width: 8),
                        CardOption('Sons', Icons.volume_up, onTap: (name) {
                          _handleCardOptionTap(name);
                        }),
                        const SizedBox(width: 8),
                        CardOption('Dados', Icons.data_usage, onTap: (name) {
                          _handleCardOptionTap(name);
                        }),
                      ],
                    ),
                  ],
                  if (_selectedTypeForm.isNotEmpty &&
                      _selectedTypeForm == 'Avaliar Comportamento') ...[
                    Row(
                      children: [
                        CardOption('Jogos', Icons.games,
                            onTap: (name) => _handleCardOptionTap(name)),
                      ],
                    ),
                  ],
                  if (_name == 'Jogos') ...[
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: GameDao().getAll(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final items = snapshot.data ?? [];
                          return Column(
                            children: items.map((item) {
                              // Cria um ValueNotifier para rastrear se a questão está na lista de análise
                              ValueNotifier<bool> isIncludedInAnalysisGame =
                                  ValueNotifier(
                                _avaliarComportamentoElements
                                    .any((element) => element[1] == item['id']),
                              );

                              return GestureDetector(
                                onTap: () {
                                  //
                                  _addElementToAvaliarComportamento(
                                      'games', item['id']);
                                  isIncludedInAnalysisGame.value =
                                      !isIncludedInAnalysisGame.value;
                                },
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: isIncludedInAnalysisGame,
                                  builder: (context, isIncluded, _) {
                                    return GameComponent(
                                      item['name'],
                                      item['link'],
                                      id: item['id'],
                                      backgroundColor: isIncluded
                                          ? Colors.green
                                          : Colors.white,
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                  if (_name == 'Sons') ...[
                    Sounds(
                        analiseInfoElements: _analiseInfoElements,
                        addElementToAnaliseInfo: _addElementToAnaliseInfo,
                        currentPlaying: _currentPlayingSound,
                        soundPlayer: _audioPlayer),
                  ],
                  if (_name == 'Dados') ...[
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                    "Start Date: ${DateFormat('yyyy-MM-dd').format(startDate!)}"),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: _pickStartDate,
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                    "End Date: ${DateFormat('yyyy-MM-dd').format(endDate!)}"),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: _pickEndDate,
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder(
                          future: futureJsonData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                (snapshot.data
                                        as Map<String, List<List<dynamic>>>)
                                    .isEmpty) {
                              return const Center(
                                  child: Text('No data available'));
                            } else {
                              Map<String, List<List<dynamic>>> allJsonData =
                                  snapshot.data
                                      as Map<String, List<List<dynamic>>>;

                              return SingleChildScrollView(
                                child: Column(
                                  children: allJsonData.keys.map((game) {
                                    return ValueListenableBuilder<bool>(
                                      valueListenable: ValueNotifier(
                                          _analiseInfoElements.any((element) =>
                                              element[0] == 'json_data' &&
                                              element[1] == game)),
                                      builder: (context, isIncluded, _) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onLongPress: () {
                                                setState(() {
                                                  handleExpansionChange(game,
                                                      startDate, endDate, true);
                                                });
                                              },
                                              child: ChartData(
                                                idPatient: widget.idPatient,
                                                startDate: startDate!,
                                                endDate: endDate!,
                                                game: game,
                                                selectedColor: isIncluded
                                                    ? Colors.green
                                                    : null, // Cor opcional
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  if (_name == 'Perguntas') ...[
                    Questions(
                      analiseInfoElements: _analiseInfoElements,
                      addElementToAnaliseInfo: _addElementToAnaliseInfo,
                    ),
                  ],
                ],
              ),
            ),
            if (_selectedTypeForm == 'Analise de informações') ...[
              ElevatedButton(
                onPressed: () {
                  _audioPlayer.stop();
                  _currentPlayingSound.value = null;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayElementsScreen(
                        elements: _analiseInfoElements,
                        idPatient: widget.idPatient,
                      ),
                    ),
                  );
                },
                child: const Text('Ver Elementos Analisados'),
              ),
            ] else if (_selectedTypeForm == 'Avaliar Comportamento') ...[
              ElevatedButton(
                onPressed: _createSession,
                child: const Text('Criar Sessão'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
