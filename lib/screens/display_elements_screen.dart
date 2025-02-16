import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/components/sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/chart_display.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/text_response_dao.dart';
import 'package:app_asd_diagnostic/db/option_response_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_response_dao.dart';

class DisplayElementsScreen extends StatefulWidget {
  final List<List<dynamic>> elements;
  final int idPatient;

  const DisplayElementsScreen(
      {Key? key, required this.elements, required this.idPatient})
      : super(key: key);

  @override
  DisplayElementsScreenState createState() => DisplayElementsScreenState();
}

class DisplayElementsScreenState extends State<DisplayElementsScreen>
    with WidgetsBindingObserver {
  final TextEditingController _formNameController = TextEditingController();
  final List<Question> _questions = [];
  final List<Map<String, dynamic>> _jsonDataElements = [];
  final List<SoundComponent> _soundElements = [];
  final ValueNotifier<String> _currentSoundNotifier = ValueNotifier('');
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currentSoundNotifier.value = '';
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _currentSoundNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer.stop();
      _currentSoundNotifier.value = '';
    }
  }

  Future<List<Widget>> componentsPage(List<List<dynamic>> elements) async {
    List<Widget> avaliarComportamentoElements = [];

    for (List<dynamic> element in elements) {
      if (element.isNotEmpty && element[0] == 'json_data') {
        final jsonData = ChartData(
          idPatient: widget.idPatient,
          startDate: element[2],
          endDate: element[3],
          game: element[1],
        );
        _jsonDataElements.add({
          'id_patient': widget.idPatient,
          'start_date': element[2],
          'end_date': element[3],
          'game': element[1],
        });
        avaliarComportamentoElements.add(jsonData);
      } else if (element.isNotEmpty && element[0] == 'questions') {
        final questionDao = QuestionDao();
        final question = await questionDao.getOne(element[1]);
        _questions.add(question);
        avaliarComportamentoElements.add(
          Column(
            children: [
              question,
            ],
          ),
        );
      } else if (element.isNotEmpty && element[0] == 'sounds') {
        int soundId = element[1];
        final soundComponent = SoundComponent(
          soundId: soundId,
          currentPlaying: _currentSoundNotifier,
          audioPlayer: _audioPlayer,
        );
        _soundElements.add(soundComponent);
        avaliarComportamentoElements.add(soundComponent);
      }
    }
    return avaliarComportamentoElements;
  }

  Future<void> _createForm() async {
    final formDao = FormDao();
    final textResponseDao = TextResponseDao();
    final optionResponseDao = OptionResponseDao();
    final jsonDataResponseDao = JsonDataResponseDao();
    final soundResponseDao = SoundResponseDao();

    final formName = _formNameController.text.trim();
    if (formName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira o nome do formulário.')),
      );
      return;
    }

    final createdAt = DateTime.now().toUtc().toString();

    final formId = await formDao.insertForm({
      'name': formName,
      'id_patient': widget.idPatient,
      'created_at': createdAt,
    });

    for (var question in _questions) {
      if (question.answerOptions != null) {
        final selectedOption = question.selectedOptionNotifier.value;
        if (selectedOption != null) {
          await optionResponseDao.insertResponse({
            'form_id': formId,
            'question_id': question.id,
            'option_id': selectedOption,
          });
        }
      } else {
        final responseText = question.textController.text;
        await textResponseDao.insertResponse({
          'form_id': formId,
          'question_id': question.id,
          'response_text': responseText,
        });
      }
    }

    for (var sound in _soundElements) {
      await soundResponseDao.insertResponse({
        'form_id': formId,
        'sound_id': sound.soundId,
        'text_response': sound.textController.text,
      });
    }

    for (var jsonData in _jsonDataElements) {
      await jsonDataResponseDao.insertResponse({
        'form_id': formId,
        'id_patient': jsonData['id_patient'],
        'start_date': jsonData['start_date'].toString(),
        'end_date': jsonData['end_date'].toString(),
        'game': jsonData['game'],
      });
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/initial',
      arguments: {'patientId': widget.idPatient.toString()},
      (Route<dynamic> route) => false, // Remove todas as rotas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBar(title: 'Criar formulário', showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Widget>>(
          future: componentsPage(widget.elements),
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum dado adicionado'));
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _formNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Formulário',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...snapshot.data!,
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Criar Formulário',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
