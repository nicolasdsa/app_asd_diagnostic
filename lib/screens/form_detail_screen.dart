import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/text_response_dao.dart';
import 'package:app_asd_diagnostic/db/option_response_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_response_dao.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/components/sound.dart';
import 'package:app_asd_diagnostic/screens/components/chart_display.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FormDetailScreen extends StatelessWidget {
  final int formId;
  Map<String, List<GlobalKey>> _repaintBoundaryKeys = {};

  FormDetailScreen({Key? key, required this.formId}) : super(key: key);

  void _onKeysGenerated(String game, List<GlobalKey> keys) {
    // Substituir as chaves antigas pelas novas
    _repaintBoundaryKeys[game] =
        List.from(keys); // Sobrescreve a lista existente
  }

  Future<Map<String, dynamic>> _fetchFormDetails() async {
    final formDao = FormDao();
    final textResponseDao = TextResponseDao();
    final optionResponseDao = OptionResponseDao();
    final jsonDataResponseDao = JsonDataResponseDao();
    final soundResponseDao = SoundResponseDao();

    final form = await formDao.getForm(formId);
    final textResponses = await textResponseDao.getResponsesForForm(formId);
    final optionResponses = await optionResponseDao.getResponsesForForm(formId);
    final jsonDataResponses =
        await jsonDataResponseDao.getResponsesForForm(formId);
    final soundResponses = await soundResponseDao.getResponsesForForm(formId);

    return {
      'form': form,
      'textResponses': textResponses,
      'optionResponses': optionResponses,
      'jsonDataResponses': jsonDataResponses,
      'soundResponses': soundResponses, // Adiciona as respostas de som ao mapa
    };
  }

  Future<Uint8List?> _capturePng(GlobalKey key) async {
    try {
      // Espera pequena para garantir que o render seja concluído
      await Future.delayed(const Duration(milliseconds: 100));

      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        // Se o render ainda não está pronto, espera e tenta novamente
        await Future.delayed(const Duration(milliseconds: 100));
        return _capturePng(key);
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Erro ao capturar imagem: $e");
      return null;
    }
  }

  void _captureScreenshots(BuildContext context) async {
    final pdf = pw.Document();

    // Carrega a fonte personalizada com suporte a Unicode
    final customFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final customFontBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final optionResponseDao = OptionResponseDao();
    final questionOptions = await optionResponseDao.getQuestionsForForm(formId);

    final textResponseDao = TextResponseDao();
    final textQuestions = await textResponseDao.getQuestionsForForm(formId);

    for (var textData in textQuestions) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  textData['question_text'],
                  style: pw.TextStyle(
                    fontSize: 16,
                    font: customFontBold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  textData['response_text'],
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: customFont,
                  ),
                ),
                pw.SizedBox(height: 10), // Espaço após a resposta
              ],
            );
          },
        ),
      );
    }

    // Adiciona cada pergunta e suas opções ao PDF
    for (var questionData in questionOptions) {
      String questionText = questionData['question_text'];
      List<dynamic> options = questionData['options'];
      int selectedOptionIndex = questionData['answer'];

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  questionText,
                  style: pw.TextStyle(
                    fontSize: 16,
                    font: customFontBold,
                  ),
                ),
                pw.SizedBox(height: 5),
                ...options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          option,
                          style: pw.TextStyle(
                            fontSize: 14,
                            font: customFont,
                          ),
                        ),
                        if (index == selectedOptionIndex)
                          pw.Text(
                            ' (Selecionado)',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.blue,
                              font: customFontBold,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                pw.SizedBox(height: 10), // Espaço após as opções
              ],
            );
          },
        ),
      );
    }

    // Adiciona as imagens e o título conforme o código existente
    for (var entry in _repaintBoundaryKeys.entries) {
      String game = entry.key;
      List<GlobalKey> keys = entry.value;

      final List<pw.Widget> imageWidgets = [];

      for (var key in keys) {
        final image = await _capturePng(key);
        if (image != null) {
          final imageProvider = pw.MemoryImage(image);
          imageWidgets.add(pw.Image(imageProvider,
              fit: pw.BoxFit.contain, width: 200, height: 200));
        }
      }

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Título: $game',
                  style: pw.TextStyle(
                    fontSize: 18,
                    font: customFontBold,
                  ),
                ),
                pw.SizedBox(height: 10), // Espaço após o título
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: imageWidgets,
                ),
              ],
            );
          },
        ),
      );
    }

    final Directory? downloadsDirectory = await getExternalStorageDirectory();
    final pdfPath = '${downloadsDirectory!.path}/screenshots.pdf';

    final file = File(pdfPath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvo em $pdfPath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Formulário',
            style: Theme.of(context).textTheme.headlineLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: 20,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _captureScreenshots(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchFormDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Nenhum dado encontrado'));
            } else {
              final form = snapshot.data!['form'] as FormUser;
              final textResponses =
                  snapshot.data!['textResponses'] as List<Question>;
              final optionResponses =
                  snapshot.data!['optionResponses'] as List<Question>;
              final jsonDataResponses = snapshot.data!['jsonDataResponses']
                  as List<Map<String, dynamic>>;
              final soundResponses =
                  snapshot.data!['soundResponses'] as List<SoundComponent>;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome do Formulário: ${form.name}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    if (textResponses.isNotEmpty) ...[
                      ...textResponses.map((response) {
                        return response;
                      }).toList(),
                    ],
                    if (optionResponses.isNotEmpty) ...[
                      ...optionResponses.map((response) {
                        return response;
                      }).toList(),
                    ],
                    if (jsonDataResponses.isNotEmpty) ...[
                      ...jsonDataResponses.map((response) {
                        return ChartData(
                          idPatient: response['id_patient'],
                          startDate: DateTime.parse(response['start_date']),
                          endDate: DateTime.parse(response['end_date']),
                          game: response['game'],
                          initiallyExpanded: true,
                          onKeysGenerated: (keys) =>
                              _onKeysGenerated(response['game'], keys),
                        );
                      }).toList(),
                    ],
                    if (soundResponses.isNotEmpty) ...[
                      ...soundResponses.map((response) {
                        return response;
                      }).toList(),
                    ],
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
