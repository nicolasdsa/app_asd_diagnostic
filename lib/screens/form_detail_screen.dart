import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:audioplayers/audioplayers.dart';
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
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class FormDetailScreen extends StatefulWidget {
  final int formId;

  const FormDetailScreen({Key? key, required this.formId}) : super(key: key);

  @override
  State<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailScreen>
    with WidgetsBindingObserver {
  Map<String, List<GlobalKey>> _repaintBoundaryKeys = {};

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

    final form = await formDao.getForm(widget.formId);
    final textResponses =
        await textResponseDao.getResponsesForForm(widget.formId);
    final optionResponses =
        await optionResponseDao.getResponsesForForm(widget.formId);
    final jsonDataResponses =
        await jsonDataResponseDao.getResponsesForForm(widget.formId);
    final soundResponsesTest =
        await soundResponseDao.getResponsesForForm(widget.formId);
    List<SoundComponent> soundComponents = [];

    for (var soundResponse in soundResponsesTest) {
      var soundComponent = SoundComponent(
        soundId: soundResponse["id"] as int,
        showEditDeleteButtons: false,
        initialText: soundResponse["text_response"] as String,
        name: soundResponse["name"] as String,
        currentPlaying: _currentSoundNotifier,
        audioPlayer: _audioPlayer,
      );
      soundComponents.add(soundComponent);
    }

    return {
      'form': form,
      'textResponses': textResponses,
      'optionResponses': optionResponses,
      'jsonDataResponses': jsonDataResponses,
      'soundResponses': soundComponents, // Adiciona as respostas de som ao mapa
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
    final questionOptions =
        await optionResponseDao.getQuestionsForForm(widget.formId);

    final textResponseDao = TextResponseDao();
    final textQuestions =
        await textResponseDao.getQuestionsForForm(widget.formId);

    final soundResponseDao = SoundResponseDao();
    final soundResponses =
        await soundResponseDao.getResponsesForForm(widget.formId);

    // Fonte de fallback para suportar o caractere "●"
    final symbolFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansSymbols.ttf'));

    final boldTextStyleWithFallback = pw.TextStyle(
      font: customFontBold,
      fontFallback: [symbolFont],
    );

    // Seção de Questões Simples
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text(
            'Questões - Simples',
            style: pw.TextStyle(fontSize: 18, font: customFontBold),
          ),
          pw.SizedBox(height: 10),
          ...textQuestions.map((textData) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  textData['question_text'],
                  style: pw.TextStyle(fontSize: 16, font: customFontBold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  textData['response_text'],
                  style: pw.TextStyle(fontSize: 14, font: customFont),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );

    // Seção de Questões Múltipla Escolha
    // Seção de Questões Múltipla Escolha
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text(
            'Questões - Múltipla Escolha',
            style: pw.TextStyle(fontSize: 18, font: customFontBold),
          ),
          pw.SizedBox(height: 10),
          ...questionOptions.map((questionData) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  questionData['question_text'],
                  style: pw.TextStyle(fontSize: 16, font: customFontBold),
                ),
                pw.SizedBox(height: 5),
                ...questionData['options'].asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  bool isSelected = index == questionData['answer'];

                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          isSelected
                              ? '•'
                              : 'O', // ● para marcado, O para não marcado
                          style: boldTextStyleWithFallback,
                        ),
                        pw.SizedBox(width: 5),
                        pw.Text(
                          option,
                          style: pw.TextStyle(
                            fontSize: 14,
                            font: customFont,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                pw.SizedBox(height: 10),
                pw.Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
    // Seção de Sons
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text(
            'Sons',
            style: pw.TextStyle(fontSize: 18, font: customFontBold),
          ),
          pw.SizedBox(height: 10),
          ...soundResponses.map((soundData) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  soundData['name'] as String,
                  style: pw.TextStyle(fontSize: 16, font: customFontBold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  soundData['text_response'] as String,
                  style: pw.TextStyle(fontSize: 14, font: customFont),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
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
                  game,
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

    final String timestamp =
        DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());

    final Map<String, dynamic> formData =
        await FormDao().getOneForm(widget.formId);

    final Map<String, dynamic> patientData =
        await PatientDao().getPatientById(formData['id_patient']);
    final String patientName = patientData['name'];

    final fileBytes = await pdf.save();

    // Crie um arquivo temporário para salvar o PDF antes de abrir o diálogo
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/$patientName-$timestamp.pdf';
    final File tempFile = File(tempPath);
    await tempFile.writeAsBytes(fileBytes);

    // Use o FlutterFileDialog para permitir que o usuário escolha o local
    final params = SaveFileDialogParams(
      sourceFilePath: tempPath,
      fileName: '$patientName-$timestamp.pdf',
    );
    await FlutterFileDialog.saveFile(params: params);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF exportado com sucesso!')),
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
            icon: const Icon(Icons.picture_as_pdf),
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
