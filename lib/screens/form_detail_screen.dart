import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:app_asd_diagnostic/db/user.dart';
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

  pw.MemoryImage? _checkIcon;
  pw.MemoryImage? _circleIcon;
  pw.MemoryImage? _speakerIcon;
  pw.MemoryImage? _headPhoneIcon;
  pw.MemoryImage? _cognitiveIcon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCheckIcon();
  }

  Future<void> _loadCheckIcon() async {
    final bytes =
        (await rootBundle.load('assets/images/screens/check_green.png'))
            .buffer
            .asUint8List();

    final bytesBlue =
        (await rootBundle.load('assets/images/screens/circle_blue.png'))
            .buffer
            .asUint8List();

    final bytesSpeaker =
        (await rootBundle.load('assets/images/screens/speaker_purple.png'))
            .buffer
            .asUint8List();

    final bytesHeadphone =
        (await rootBundle.load('assets/images/screens/headphones_green.png'))
            .buffer
            .asUint8List();

    final bytesCognitive = (await rootBundle
            .load('assets/images/screens/cognitive_icon_purple.png'))
        .buffer
        .asUint8List();

    setState(() {
      _checkIcon = pw.MemoryImage(bytes);
      _circleIcon = pw.MemoryImage(bytesBlue);
      _speakerIcon = pw.MemoryImage(bytesSpeaker);
      _headPhoneIcon = pw.MemoryImage(bytesHeadphone);
      _cognitiveIcon = pw.MemoryImage(bytesCognitive);
    });
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

  pw.Widget _buildHeader({
    required pw.Font regular,
    required pw.Font bold,
    required Map<String, dynamic> user,
    required DateTime formDate,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título + dados do profissional
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'RELATÓRIO DE AVALIAÇÃO NEUROPSICOLÓGICA',
              style: pw.TextStyle(font: bold, fontSize: 14),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Mostra apenas o primeiro e o último nome do usuário
                pw.Text(
                  () {
                    final fullName = (user['name'] ?? '').toString().trim();
                    final parts = fullName.split(RegExp(r'\s+'));
                    if (parts.length <= 1) return fullName;
                    return '${parts.first} ${parts.last}';
                  }(),
                  style: pw.TextStyle(font: bold),
                ),
                pw.Text('${user['institute'] ?? ''}',
                    style: pw.TextStyle(font: regular)),
                pw.Text('CRM: ${user['crm'] ?? ''}',
                    style: pw.TextStyle(font: regular)),
                pw.Text('${user['email'] ?? ''}',
                    style: pw.TextStyle(font: regular)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        // Data e tipo
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(formDate)}',
              style: pw.TextStyle(font: regular, fontSize: 10),
            ),
          ],
        ),
        pw.Divider(thickness: 1),
      ],
    );
  }

  pw.Widget _buildPatientBox({
    required pw.Font regular,
    required pw.Font bold,
    required Map<String, dynamic> patient,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Dados do Paciente',
              style: pw.TextStyle(font: bold, fontSize: 12)),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _col(
                'Nome',
                () {
                  final fullName = (patient['name'] ?? '').toString().trim();
                  final parts = fullName.split(RegExp(r'\s+'));
                  if (parts.length <= 1) return fullName;
                  return '${parts.first} ${parts.last}';
                }(),
                regular,
                bold,
              ),
              _col('Idade', '${patient['age']} anos', regular, bold),
              _col('Gênero', patient['gender'] ?? '', regular, bold),
              _col('Diagnóstico Suspeito', patient['diagnosis'] ?? '—', regular,
                  bold),
            ],
          ),
        ],
      ),
    );
  }

// ajudante interno
  pw.Widget _col(String title, String value, pw.Font regular, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.Text(value, style: pw.TextStyle(font: regular, fontSize: 9)),
      ],
    );
  }

  pw.Widget _buildSimpleQuestionsBlock({
    required pw.Font regular,
    required pw.Font bold,
    required List<Map<String, dynamic>> questions,
  }) {
    // cores claras para intercalar linhas
    const PdfColor rowBg = PdfColor.fromInt(0xFFF8F9FA);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Cabeçalho verde com check
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Row(
              children: [
                // ícone
                if (_checkIcon != null)
                  pw.Image(_checkIcon!, width: 12, height: 12),
                pw.SizedBox(width: 4),
                // título
                pw.Text('Questões Simples',
                    style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.Spacer(),
                // badge "Concluído"
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color:
                        const PdfColor.fromInt(0xFFE6F4EA), // verde bem claro
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Concluído',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 9,
                      color: const PdfColor.fromInt(0xFF2ECC71), // verde
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.Divider(height: 1, color: PdfColors.grey300),
          // Lista de questões
          ...questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            return pw.Container(
              color: i.isEven ? rowBg : PdfColors.white,
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(q['question_text'],
                      style: pw.TextStyle(font: bold, fontSize: 10)),
                  pw.SizedBox(height: 2),
                  pw.Text(q['response_text'],
                      style: pw.TextStyle(font: regular, fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildMultipleChoiceBlock({
    required pw.Font regular,
    required pw.Font bold,
    required List<Map<String, dynamic>> questions,
    required pw.MemoryImage circleIcon,
  }) {
    final PdfColor headerBlue = PdfColor.fromInt(0xFF345FFF);
    final PdfColor badgeBg = PdfColor.fromInt(0xFFE6E9FE);
    final PdfColor badgeSelBg = PdfColor.fromInt(0xFFD6DBFD);

    // legenda explicativa
    final legend = pw.Text(
      '• opções selecionadas aparecem em azul mais escuro',
      style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey700),
    );

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Row(
              children: [
                pw.Image(circleIcon, width: 10, height: 10),
                pw.SizedBox(width: 4),
                pw.Text('Questões Múltipla Escolha',
                    style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.SizedBox(width: 6),
                legend,
                pw.Spacer(),
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: badgeBg,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Concluído',
                    style: pw.TextStyle(
                        font: bold, fontSize: 9, color: headerBlue),
                  ),
                ),
              ],
            ),
          ),
          pw.Divider(height: 1, color: PdfColors.grey300),

          // Lista
          ...questions.map((q) {
            final options = q['options'] as List<dynamic>;
            final answer = q['answer'] as int; // índice selecionado

            return pw.Container(
              color: PdfColor.fromInt(0xFFF8F9FA),
              padding: const pw.EdgeInsets.all(8),
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // enunciado
                  pw.Text(q['question_text'],
                      style: pw.TextStyle(font: bold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  // opções empilhadas
                  ...options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final text = entry.value;
                    final selected = idx == answer;

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(top: 3),
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: selected ? badgeSelBg : badgeBg,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        text,
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 8,
                          color: selected ? headerBlue : PdfColors.grey700,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildSoundBlock({
    required pw.Font regular,
    required pw.Font bold,
    required List<Map<String, dynamic>> sounds,
    required pw.MemoryImage speakerIcon, // púrpura – cabeçalho
    required pw.MemoryImage headphonesIcon, // verde – linhas
  }) {
    final PdfColor headerPurple = PdfColor.fromInt(0xFF9B59B6);
    final PdfColor badgeBg = PdfColor.fromInt(0xFFF0E8F9);
    const PdfColor rowBg = PdfColor.fromInt(0xFFF8F9FA);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Row(
              children: [
                pw.Image(speakerIcon, width: 10, height: 10),
                pw.SizedBox(width: 4),
                pw.Text('Avaliação Auditiva',
                    style: pw.TextStyle(font: bold, fontSize: 12)),
                pw.Spacer(),
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: badgeBg,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Concluído',
                    style: pw.TextStyle(
                        font: bold, fontSize: 9, color: headerPurple),
                  ),
                ),
              ],
            ),
          ),
          pw.Divider(height: 1, color: PdfColors.grey300),

          // Lista de sons
          ...sounds.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value; // Map com 'name' e 'text_response'

            return pw.Container(
              color: i.isEven ? rowBg : PdfColors.white,
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // primeira linha: ícone + nome
                  pw.Row(
                    children: [
                      pw.Image(headphonesIcon, width: 8, height: 8),
                      pw.SizedBox(width: 4),
                      pw.Text(s['name'] ?? '',
                          style: pw.TextStyle(font: bold, fontSize: 10)),
                    ],
                  ),
                  // comentário do profissional
                  if ((s['text_response'] ?? '').toString().trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 12, top: 2),
                      child: pw.Text(
                        s['text_response'],
                        style: pw.TextStyle(
                            font: regular, fontSize: 9, lineSpacing: 1.2),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildImagesBlock({
    required pw.Font regular,
    required pw.Font bold,
    required Map<String, List<Uint8List>> imagesByGame,
    required pw.MemoryImage cogIcon,
  }) {
    const PdfColor rowBg = PdfColor.fromInt(0xFFF8F9FA);
    final PdfColor headerPurple = PdfColor.fromInt(0xFF683BFF);

    // converte mapas de bytes para MemoryImage só uma vez
    pw.ImageProvider _toImg(Uint8List bytes) => pw.MemoryImage(bytes);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // cabeçalho
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Row(
              children: [
                pw.Image(cogIcon, width: 10, height: 10),
                pw.SizedBox(width: 4),
                pw.Text('Atividades Cognitivas Especializadas',
                    style: pw.TextStyle(font: bold, fontSize: 12)),
              ],
            ),
          ),
          pw.Divider(height: 1, color: PdfColors.grey300),

          // para cada jogo, imprime título + imagens
          ...imagesByGame.entries.map((e) {
            return pw.Container(
              color: rowBg,
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              margin: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.key, style: pw.TextStyle(font: bold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: e.value
                        .map((b) => pw.Image(_toImg(b), width: 120))
                        .toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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

    // 1️⃣  Dados principais
    final formData = await FormDao().getOneForm(widget.formId);
    final patientData =
        await PatientDao().getPatientById(formData['id_patient']);
    final userData =
        await UserDao().getOneId(patientData['user_id'].toString());
    final formDate = DateTime.parse(formData['created_at']);

    final Map<String, List<Uint8List>> imgs = {};
    for (var entry in _repaintBoundaryKeys.entries) {
      final List<Uint8List> bytesList = [];
      for (var key in entry.value) {
        final imgBytes = await _capturePng(key);
        if (imgBytes != null) bytesList.add(imgBytes);
      }
      if (bytesList.isNotEmpty) imgs[entry.key] = bytesList;
    }

// 3️⃣  Primeira página como MultiPage, usando o header como cabeçalho fixo
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(
          regular: customFont,
          bold: customFontBold,
          user: userData,
          formDate: formDate,
        ),
        build: (ctx) => [
          _buildPatientBox(
            regular: customFont,
            bold: customFontBold,
            patient: patientData,
          ),
          if (textQuestions.isNotEmpty)
            _buildSimpleQuestionsBlock(
              regular: customFont,
              bold: customFontBold,
              questions: textQuestions,
            ),
          if (questionOptions.isNotEmpty && _circleIcon != null)
            _buildMultipleChoiceBlock(
              regular: customFont,
              bold: customFontBold,
              questions: questionOptions,
              circleIcon: _circleIcon!,
            ),
          if (soundResponses.isNotEmpty && _speakerIcon != null)
            _buildSoundBlock(
              regular: customFont,
              bold: customFontBold,
              sounds: soundResponses,
              speakerIcon: _speakerIcon!,
              headphonesIcon: _headPhoneIcon!,
            ),
          if (imgs.isNotEmpty)
            _buildImagesBlock(
              regular: customFont,
              bold: customFontBold,
              imagesByGame: imgs,
              cogIcon: _cognitiveIcon!,
            ),
        ],
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Para dúvidas ou esclarecimentos, entre em contato com o profissional responsável.',
            style: pw.TextStyle(
              font: customFont,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ),
    );

    final String timestamp =
        DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());

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
