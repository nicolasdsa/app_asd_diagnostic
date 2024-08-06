import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/text_response_dao.dart';
import 'package:app_asd_diagnostic/db/option_response_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_response_dao.dart';
import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/components/sound.dart';
import 'package:app_asd_diagnostic/screens/components/chart_display.dart';
import 'package:intl/intl.dart';

class FormDetailScreen extends StatelessWidget {
  final int formId;

  const FormDetailScreen({Key? key, required this.formId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchFormDetails() async {
    final formDao = FormDao();
    final textResponseDao = TextResponseDao();
    final optionResponseDao = OptionResponseDao();
    final jsonDataResponseDao = JsonDataResponseDao();
    final soundResponseDao =
        SoundResponseDao(); // Instância do SoundResponseDao
    final questionDao = QuestionDao();

    final form = await formDao.getForm(formId);
    final textResponses = await textResponseDao.getResponsesForForm(formId);
    final optionResponses = await optionResponseDao.getResponsesForForm(formId);
    final jsonDataResponses =
        await jsonDataResponseDao.getResponsesForForm(formId);
    final soundResponses = await soundResponseDao
        .getResponsesForForm(formId); // Obtém as respostas de som

    // Fetch questions for text and option responses
    final questions = <int, Question>{};
    for (var response in textResponses) {
      questions[response['question_id']] =
          await questionDao.getOne(response['question_id']);
    }
    for (var response in optionResponses) {
      questions[response['question_id']] =
          await questionDao.getOne(response['question_id']);
    }

    return {
      'form': form,
      'textResponses': textResponses,
      'optionResponses': optionResponses,
      'jsonDataResponses': jsonDataResponses,
      'soundResponses': soundResponses, // Adiciona as respostas de som ao mapa
      'questions': questions,
    };
  }

  int getSelectedOptionIndex(
      List<String>? answerOptions, int selectedOptionId) {
    if (answerOptions == null) {
      return 0;
    }
    for (int i = 0; i < answerOptions.length; i++) {
      if (int.parse(answerOptions[i]) == selectedOptionId) {
        return i;
      }
    }
    return 0; // Retorna 0 se o valor não for encontrado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Formulário'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchFormDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Nenhum dado encontrado'));
          } else {
            final form = snapshot.data!['form'] as FormUser;
            final textResponses =
                snapshot.data!['textResponses'] as List<Map<String, dynamic>>;
            final optionResponses =
                snapshot.data!['optionResponses'] as List<Map<String, dynamic>>;
            final jsonDataResponses = snapshot.data!['jsonDataResponses']
                as List<Map<String, dynamic>>;
            final soundResponses = snapshot.data!['soundResponses']
                as List<Map<String, dynamic>>; // Respostas de som
            final questions = snapshot.data!['questions'] as Map<int, Question>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome do Formulário: ${form.name}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    if (textResponses.isNotEmpty) ...[
                      ...textResponses.map((response) {
                        final question = questions[response['question_id']]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(question.name,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            TextFormField(
                              initialValue: response['response_text'],
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                    if (optionResponses.isNotEmpty) ...[
                      ...optionResponses.map((response) {
                        final question = questions[response['question_id']]!;
                        final selectedOptionIndex = getSelectedOptionIndex(
                          question.answerOptionIds,
                          response['option_id'],
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(question.name,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            ...question.answerOptions!.map((option) {
                              return RadioListTile(
                                value: option,
                                groupValue: question
                                    .answerOptions![selectedOptionIndex],
                                onChanged: null,
                                title: Text(option),
                              );
                            }).toList(),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                    if (jsonDataResponses.isNotEmpty) ...[
                      ...jsonDataResponses.map((response) {
                        return ChartData(
                          idPatient: response['id_patient'],
                          startDate: DateTime.parse(response['start_date']),
                          endDate: DateTime.parse(response['end_date']),
                          game: response['game'],
                        );
                      }).toList(),
                    ],
                    if (soundResponses.isNotEmpty) ...[
                      ...soundResponses.map((response) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SoundComponent(soundId: response['sound_id']),
                            TextFormField(
                              initialValue: response[
                                  'text_response'], // Resposta de texto associada ao som
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
