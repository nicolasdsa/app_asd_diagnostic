import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/components/sound.dart';
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

  DisplayElementsScreen(
      {Key? key, required this.elements, required this.idPatient})
      : super(key: key);

  @override
  _DisplayElementsScreenState createState() => _DisplayElementsScreenState();
}

class _DisplayElementsScreenState extends State<DisplayElementsScreen> {
  List<Question> _questions = [];
  List<Map<String, dynamic>> _jsonDataElements = [];
  List<SoundComponent> _soundElements = []; // Ajuste aqui

  Future<List<Widget>> componentsPage(List<List<dynamic>> elements) async {
    List<Widget> _avaliarComportamentoElements = [];

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
        _avaliarComportamentoElements.add(jsonData);
      } else if (element.isNotEmpty && element[0] == 'questions') {
        final questionDao = QuestionDao();
        final question = await questionDao.getOne(element[1]);
        _questions.add(question);
        _avaliarComportamentoElements.add(
          Column(
            children: [
              question,
            ],
          ),
        );
      } else if (element.isNotEmpty && element[0] == 'sounds') {
        int soundId = element[1];
        final soundComponent = SoundComponent(soundId: soundId);
        _soundElements.add(soundComponent);
        _avaliarComportamentoElements.add(soundComponent);
      }
    }
    return _avaliarComportamentoElements;
  }

  Future<void> _createForm() async {
    final formDao = FormDao();
    final textResponseDao = TextResponseDao();
    final optionResponseDao = OptionResponseDao();
    final jsonDataResponseDao = JsonDataResponseDao();
    final soundResponseDao = SoundResponseDao();

    final formId = await formDao.insertForm(
        {'name': 'Novo Formulário', 'id_patient': widget.idPatient});

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
        'text_response': sound.textController.text, // Correção aqui
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Elements'),
      ),
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
                    ...snapshot.data!,
                    ElevatedButton(
                      onPressed: _createForm,
                      child: const Text('Criar Formulário'),
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
