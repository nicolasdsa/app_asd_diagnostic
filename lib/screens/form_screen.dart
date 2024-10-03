import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/screens/components/chart_display.dart';
import 'package:app_asd_diagnostic/screens/components/games.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:app_asd_diagnostic/screens/components/questions.dart';
import 'package:app_asd_diagnostic/screens/components/sounds.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/screens/display_elements_screen.dart';
import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';

class FormScreen extends StatefulWidget {
  final int idPatient;

  const FormScreen({Key? key, required this.idPatient}) : super(key: key);

  @override
  FormScreenState createState() => FormScreenState();
}

class FormScreenState extends State<FormScreen> with WidgetsBindingObserver {
  final ValueNotifier<String?> _currentPlayingSound =
      ValueNotifier<String?>(null);
  final ValueNotifier<String?> _nameNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedTypeFormNotifier =
      ValueNotifier<String?>(null);

  final _formKey = GlobalKey<FormState>();
  final _typeFormDao = TypeFormDao();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _typeFormElements = [];
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
    _nameNotifier.value = name;
  }

  void _handleTypeFormTap(String name) {
    _selectedTypeFormNotifier.value = name;
    _nameNotifier.value = null;
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

    if (_avaliarComportamentoElements
        .any((element) => listEquals(element, newElement))) {
      _avaliarComportamentoElements.removeWhere((element) => element[1] == id);
      print(
          'Elemento removido de _avaliarComportamentoElements: $_avaliarComportamentoElements');
    } else {
      _avaliarComportamentoElements.add(newElement);
      print(
          'Novo elemento adicionado em _avaliarComportamentoElements: $_avaliarComportamentoElements');
    }

    // Mostra o SnackBar fora do setStat
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget Function()> contentWidgets = {
      'Jogos': () => Games(
            avaliarComportamentoElements: _avaliarComportamentoElements,
            addElementToAvaliarComportamento: _addElementToAvaliarComportamento,
          ),
      'Sons': () => Sounds(
            analiseInfoElements: _analiseInfoElements,
            addElementToAnaliseInfo: _addElementToAnaliseInfo,
            currentPlaying: _currentPlayingSound,
            soundPlayer: _audioPlayer,
          ),
      'Dados': () => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey), // Defina a cor da borda aqui
                        borderRadius: BorderRadius.circular(
                            8.0), // Opcional: bordas arredondadas
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                            startDate != null
                                ? "Data inicial: ${DateFormat('yyyy-MM-dd').format(startDate!)}"
                                : "Data inicial",
                            style: Theme.of(context).textTheme.labelMedium),
                        onTap: _pickStartDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                            endDate != null
                                ? "Data final: ${DateFormat('yyyy-MM-dd').format(endDate!)}"
                                : "Data final",
                            style: Theme.of(context).textTheme.labelMedium),
                        onTap: _pickEndDate,
                      ),
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                future: futureJsonData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      (snapshot.data as Map<String, List<List<dynamic>>>)
                          .isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Nenhum dado encontrado')),
                    );
                  } else {
                    Map<String, List<List<dynamic>>> allJsonData =
                        snapshot.data as Map<String, List<List<dynamic>>>;

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
                                        handleExpansionChange(
                                            game, startDate, endDate, true);
                                      });
                                    },
                                    child: ChartData(
                                      idPatient: widget.idPatient,
                                      startDate: startDate!,
                                      endDate: endDate!,
                                      game: game,
                                      selectedColor:
                                          isIncluded ? Colors.grey : null,
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
      'Perguntas': () => Questions(
            analiseInfoElements: _analiseInfoElements,
            addElementToAnaliseInfo: _addElementToAnaliseInfo,
          ),
    };

    return Scaffold(
      appBar: const CustomAppBar(
          title: 'Cadastro de formulário', showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            if (_typeFormElements.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CardOption(
                    _typeFormElements[0]['name'],
                    Icons.analytics,
                    onTap: (name) => _handleTypeFormTap(name),
                    nameNotifier: _selectedTypeFormNotifier,
                  ),
                  const SizedBox(width: 8),
                  CardOption(
                    _typeFormElements[1]['name'],
                    Icons.psychology,
                    onTap: (name) => _handleTypeFormTap(name),
                    nameNotifier: _selectedTypeFormNotifier,
                  ),
                ],
              ),
            ],
            Form(
              key: _formKey,
              child: Column(
                children: [
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedTypeFormNotifier,
                    builder: (context, selectedType, child) {
                      if (selectedType == 'Analise de informações') {
                        return Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 4),
                          child: Row(
                            children: [
                              CardOption(
                                'Perguntas',
                                Icons.help,
                                onTap: (name) => _handleCardOptionTap(name),
                                nameNotifier: _nameNotifier,
                              ),
                              const SizedBox(width: 8),
                              CardOption(
                                'Sons',
                                Icons.volume_up,
                                onTap: (name) => _handleCardOptionTap(name),
                                nameNotifier: _nameNotifier,
                              ),
                              const SizedBox(width: 8),
                              CardOption(
                                'Dados',
                                Icons.data_usage,
                                onTap: (name) => _handleCardOptionTap(name),
                                nameNotifier: _nameNotifier,
                              ),
                            ],
                          ),
                        );
                      } else if (selectedType == 'Avaliar Comportamento') {
                        return Column(
                          children: [
                            Row(
                              children: [
                                CardOption(
                                  'Jogos',
                                  Icons.games,
                                  onTap: (name) => _handleCardOptionTap(name),
                                  nameNotifier: _nameNotifier,
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: _nameNotifier,
                    builder: (context, selectedOption, child) {
                      if (selectedOption != null &&
                          contentWidgets.containsKey(selectedOption)) {
                        return contentWidgets[selectedOption]!();
                      }
                      return const SizedBox();
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: _selectedTypeFormNotifier,
                    builder: (context, selectedOption, child) {
                      if (_selectedTypeFormNotifier.value ==
                          'Analise de informações') {
                        return ElevatedButton(
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
                        );
                      }
                      if (_selectedTypeFormNotifier.value ==
                          'Avaliar Comportamento') {
                        return ElevatedButton(
                          onPressed: () {
                            _audioPlayer.stop();
                            _currentPlayingSound.value = null;
                            Navigator.pushNamed(
                              context,
                              '/game',
                              arguments: {
                                'idPatient': widget.idPatient,
                                'elements': _avaliarComportamentoElements
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Criar Sessão',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
