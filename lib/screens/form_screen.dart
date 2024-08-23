import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:app_asd_diagnostic/models/sound.dart';
import 'package:app_asd_diagnostic/screens/questions_create_screen.dart';
import 'package:app_asd_diagnostic/screens/sound_list_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
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

import 'package:intl/intl.dart';

class FormScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  FormScreen({Key? key, required this.formChangeNotifier}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> with WidgetsBindingObserver {
  late ValueNotifier<int> questionChangeNotifier;
  final _formKey = GlobalKey<FormState>();
  final _typeFormDao = TypeFormDao();
  final _hashAccessDao = HashAccessDao();

  List<Map<String, dynamic>> _typeFormElements = [];

  String _name = '';
  String _selectedTypeForm = '';
  String _selectedPatientId = '1';

  List<List<dynamic>> _analiseInfoElements = [];
  List<List<dynamic>> _avaliarComportamentoElements = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SoundDao _soundDao = SoundDao();
  List<Sound> _sounds = [];
  String? _currentPlayingSound;
  String? _selectedFilePath;
  final JsonDataDao jsonDataDao = JsonDataDao();
  late Future<Map<String, List<List<dynamic>>>> futureJsonData;
  DateTime? startDate;
  DateTime? endDate;
  Map<String, bool> expandedGames = {};
  String? selectedGame;

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
        int? selectedPatientId = int.tryParse(_selectedPatientId);
        if (selectedPatientId != null) {
          futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
              selectedPatientId, startDate!, endDate!);
        }
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
        int? selectedPatientId = int.tryParse(_selectedPatientId);
        if (selectedPatientId != null) {
          futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
              selectedPatientId, startDate!, endDate!);
        }

        handleExpansionChange(selectedGame, startDate, endDate, false);
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer
        .dispose(); // Libera os recursos do player quando o widget é removido
    WidgetsBinding.instance
        .removeObserver(this); // Remove o observador do ciclo de vida
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer
          .stop(); // Para o áudio se o aplicativo for para o background ou for fechado
    }
  }

  void _showAddSoundDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Som'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.audio);
                  if (result != null) {
                    setState(() {
                      _selectedFilePath = result.files.single.path!;
                    });
                  }
                },
                child: Text('Escolher Arquivo de Som'),
              ),
              if (_selectedFilePath != null) Text('Arquivo selecionado!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_selectedFilePath != null &&
                    nameController.text.isNotEmpty) {
                  final sound = Sound(
                    name: nameController.text,
                    filePath: _selectedFilePath!,
                  );
                  _addSound(sound);
                  Navigator.pop(context);
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSound(Sound sound) async {
    await _soundDao.insert(sound);
    _fetchSounds();
  }

  Future<void> _fetchSounds() async {
    final sounds = await _soundDao.getAll();
    setState(() {
      _sounds = sounds;
    });
  }

  Future<void> _deleteSound(int id) async {
    await _soundDao.delete(id);
    _fetchSounds();
  }

  void _playSound(String filePath) async {
    if (_currentPlayingSound == filePath) {
      await _audioPlayer.stop();
      setState(() {
        _currentPlayingSound = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(UrlSource(filePath));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource(filePath));
      setState(() {
        _currentPlayingSound = filePath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(Duration(days: 30));
    endDate = DateTime.now();

    int? selectedPatientId = int.tryParse(_selectedPatientId);
    if (selectedPatientId != null) {
      futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
          selectedPatientId, startDate!, endDate!);
    }

    questionChangeNotifier = ValueNotifier(0);
    WidgetsBinding.instance
        .addObserver(this); // Adiciona o observador do ciclo de vida
  }

  void stopSound() async {
    if (_currentPlayingSound != null) {
      await _audioPlayer.stop();
      setState(() {
        _currentPlayingSound = null;
      });
    }
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
                          CardOption('Perguntas', Icons.help, onTap: (name) {
                            stopSound();
                            _handleCardOptionTap(name);
                          }),
                          const SizedBox(width: 8),
                          CardOption('Sons', Icons.volume_up, onTap: (name) {
                            stopSound();
                            _handleCardOptionTap(name);
                          }),
                          const SizedBox(width: 8),
                          CardOption('Dados', Icons.data_usage, onTap: (name) {
                            stopSound();
                            _handleCardOptionTap(name);
                          }),
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
                                  _analiseInfoElements.any(
                                      (element) => element[1] == item['id']),
                                );

                                return GestureDetector(
                                  onTap: () {
                                    _addElementToAnaliseInfo(
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
                      FutureBuilder<List<Sound>>(
                        future: SoundDao().getAll(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final sounds = snapshot.data ?? [];
                            return Column(
                              children: sounds.map((sound) {
                                // Cria um ValueNotifier para rastrear se o som está na lista de análise
                                ValueNotifier<bool> isIncludedInAnalysis =
                                    ValueNotifier(
                                  _analiseInfoElements
                                      .any((element) => element[1] == sound.id),
                                );

                                return GestureDetector(
                                  onTap: () {
                                    _addElementToAnaliseInfo(
                                        'sounds', sound.id);
                                    isIncludedInAnalysis.value =
                                        !isIncludedInAnalysis.value;
                                  },
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: isIncludedInAnalysis,
                                    builder: (context, isIncluded, _) {
                                      return ListTile(
                                        leading: IconButton(
                                          icon: Icon(
                                            _currentPlayingSound ==
                                                    sound.filePath
                                                ? Icons.stop
                                                : Icons.play_arrow,
                                          ),
                                          onPressed: () =>
                                              _playSound(sound.filePath),
                                        ),
                                        title: Text(sound.name),
                                        tileColor: isIncluded
                                            ? Colors.green
                                            : Colors.white,
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () =>
                                              _deleteSound(sound.id!),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _showAddSoundDialog,
                          child: Text('Adicionar Som'),
                        ),
                      ),
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
                                  trailing: Icon(Icons.calendar_today),
                                  onTap: _pickStartDate,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                      "End Date: ${DateFormat('yyyy-MM-dd').format(endDate!)}"),
                                  trailing: Icon(Icons.calendar_today),
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
                                      bool isExpanded =
                                          expandedGames[game] ?? false;

                                      ValueNotifier<bool> isInAnaliseInfo =
                                          ValueNotifier(_analiseInfoElements
                                              .any((element) =>
                                                  element[0] == 'json_data' &&
                                                  element[1] == game));
                                      return ValueListenableBuilder<bool>(
                                        valueListenable: isInAnaliseInfo,
                                        builder: (context, isIncluded, _) {
                                          print(isIncluded);
                                          return Column(
                                            children: [
                                              ListTile(
                                                tileColor: isIncluded
                                                    ? Colors.green[100]
                                                    : Colors.white,
                                                title: Text(
                                                  game,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Icon(
                                                  isExpanded
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    expandedGames[game] =
                                                        !isExpanded;
                                                    selectedGame = game;
                                                  });
                                                },
                                                onLongPress: () {
                                                  setState(() {
                                                    handleExpansionChange(
                                                        game,
                                                        startDate,
                                                        endDate,
                                                        true);
                                                  });
                                                },
                                              ),
                                              if (isExpanded)
                                                ...allJsonData[game]!
                                                    .map((chartData) {
                                                  String chartTitle =
                                                      chartData[0];
                                                  List<FlSpot> spots =
                                                      List.generate(
                                                          chartData[1].length,
                                                          (index) {
                                                    var dataPoint =
                                                        chartData[1][index];
                                                    return FlSpot(
                                                        index.toDouble(),
                                                        double.parse(
                                                            dataPoint[0]
                                                                .toString()));
                                                  });

                                                  List<String> dates =
                                                      chartData[1].map<String>(
                                                          (dataPoint) {
                                                    var date = dataPoint[1];
                                                    return date != null
                                                        ? DateFormat('dd/MM')
                                                            .format(
                                                                DateTime.parse(
                                                                    date))
                                                        : '';
                                                  }).toList();

                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          chartTitle,
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 300,
                                                        child: LineChart(
                                                          LineChartData(
                                                            lineBarsData: [
                                                              LineChartBarData(
                                                                spots: spots,
                                                                isCurved: true,
                                                                color:
                                                                    Colors.blue,
                                                                barWidth: 4,
                                                                isStrokeCapRound:
                                                                    true,
                                                                dotData:
                                                                    const FlDotData(
                                                                        show:
                                                                            true),
                                                              ),
                                                            ],
                                                            titlesData:
                                                                FlTitlesData(
                                                              show: true,
                                                              rightTitles:
                                                                  AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                        showTitles:
                                                                            false),
                                                              ),
                                                              topTitles:
                                                                  AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                        showTitles:
                                                                            false),
                                                              ),
                                                              bottomTitles:
                                                                  AxisTitles(
                                                                sideTitles:
                                                                    SideTitles(
                                                                  showTitles:
                                                                      true,
                                                                  reservedSize:
                                                                      32,
                                                                  interval: 1,
                                                                  getTitlesWidget: (value,
                                                                          meta) =>
                                                                      bottomTitleWidgets(
                                                                          value,
                                                                          meta,
                                                                          dates),
                                                                ),
                                                              ),
                                                            ),
                                                            minX: 0,
                                                            minY: 0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
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
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: QuestionDao().getAll(),
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
                                ValueNotifier<bool> isIncludedInAnalysis =
                                    ValueNotifier(
                                  _analiseInfoElements.any(
                                      (element) => element[1] == item['id']),
                                );

                                return FutureBuilder<String>(
                                  future: TypeQuestionDao()
                                      .getTypeQuestionName(item['id_type']),
                                  builder: (context, typeSnapshot) {
                                    if (typeSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (typeSnapshot.hasError) {
                                      return Text(
                                          'Error: ${typeSnapshot.error}');
                                    } else {
                                      final nameTypeQuestion =
                                          typeSnapshot.data ?? '';

                                      return FutureBuilder<
                                          List<Map<String, dynamic>>>(
                                        future: AnswerOptionsDao()
                                            .getOptionsForQuestion(item['id']),
                                        builder: (context, optionsSnapshot) {
                                          List<String>? answerOptions;
                                          List<String>? answerOptionIds;

                                          if (optionsSnapshot.hasData) {
                                            answerOptions = optionsSnapshot
                                                .data!
                                                .map((option) =>
                                                    option['option_text']
                                                        as String)
                                                .toList();

                                            answerOptionIds = optionsSnapshot
                                                .data!
                                                .map((option) =>
                                                    option['id'].toString())
                                                .toList();
                                          }

                                          return GestureDetector(
                                            onTap: () {
                                              _addElementToAnaliseInfo(
                                                  'questions', item['id']);
                                              isIncludedInAnalysis.value =
                                                  !isIncludedInAnalysis.value;
                                            },
                                            child: ValueListenableBuilder<bool>(
                                              valueListenable:
                                                  isIncludedInAnalysis,
                                              builder:
                                                  (context, isIncluded, _) {
                                                return Question(
                                                  item['id'],
                                                  item['question'],
                                                  nameTypeQuestion,
                                                  answerOptions,
                                                  false, // Ou false, dependendo da lógica
                                                  ValueNotifier<String?>(null),
                                                  TextEditingController(),
                                                  answerOptionIds,
                                                  ValueNotifier<String?>(null),
                                                  backgroundColor: isIncluded
                                                      ? Colors.green
                                                      : Colors.white,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionCreateScreen(
                                questionChangeNotifier: questionChangeNotifier,
                              ),
                            ),
                          );
                        },
                        child: const Text('Adicionar pergunta'),
                      ),
                    ],
                  ],
                ),
              ),
              if (_selectedTypeForm == 'Analise de informações') ...[
                ElevatedButton(
                  onPressed: () {
                    stopSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisplayElementsScreen(
                          elements: _analiseInfoElements,
                          idPatient: int.parse(_selectedPatientId),
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
      ),
    );
  }
}
