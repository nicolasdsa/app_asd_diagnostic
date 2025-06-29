import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/background.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/cloud.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/game_stats.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letters_container.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/tip.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/word_box.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:app_asd_diagnostic/db/words_dao.dart';
import 'dart:math';
import 'dart:async';

class JogoFormaPalavrasGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  final WordsDao _wordsDao = WordsDao();
  final Set<int> _usedWordIds = {};
  final List<Map<String, dynamic>> _currentWords = [];
  final List<WordBox> _wordBoxes = [];
  LettersContainer? _lettersContainer;
  final GameStats _stats = GameStats();
  late DateTime _phaseStartTime;
  bool _phaseHadError = false;
  bool _phaseHadTip = false;
  bool _levelCompleted = false;
  late final List<Map<String, dynamic>> _allWords;
  Timer? _tipTimer; // Timer para exibir dicas
  Tip? _currentTip;
  bool _isTransitioning = false; // nova flag

  JogoFormaPalavrasGame({
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;

  void onWordSolved() {
    _resetTipTimer(); // some a dica atual + reinicia cronômetro
    checkPalavrasCompletas(); // verá se todas as palavras do nível já foram feitas
  }

  // Jogador acertou a palavra
  void onWordCorrect() {
    _resetTipTimer(); // some a dica e inicia novo timer
    checkPalavrasCompletas(); // confere fim de fase
  }

  // Jogador errou a palavra
  void onWordWrong(int wrongLetters) {
    _resetTipTimer();

    // --------- Estatísticas ---------
    _stats.addWrongLetters(wrongLetters);
    if (!_phaseHadError) {
      _stats.addErrorPhase(1);
      _phaseHadError = true;
    }
  }

  void onWrongLetterTap(int n) {
    _stats.addWrongLetters(n);
    if (!_phaseHadError) {
      _stats.addErrorPhase(1);
      _phaseHadError = true;
    }
  }

  @override
  Future<void> onLoad() async {
    // 1) carrega todas as palavras de uma vez
    _allWords = await _wordsDao.getWords();

    _startNewPhase(); // stats, timers, etc.
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(canvasSize.x, canvasSize.y),
    );

    await add(Background());
    await add(Cloud());

    // 2) monta o nível 1
    await _loadAndBuildLevel();
  }

  void _startNewPhase() {
    _stats.startNewPhase();
    _phaseStartTime = DateTime.now();
    _phaseHadError = false;
    _phaseHadTip = false;
    _startTipTimer(); // timer só começa quando inicia fase
  }

  void _startTipTimer() {
    _tipTimer?.cancel(); // Cancela o timer anterior, se existir
    _tipTimer = Timer(const Duration(seconds: 4), _showTip);
  }

  void _resetTipTimer() {
    _startTipTimer(); // Reinicia o timer
    if (_currentTip != null) {
      remove(_currentTip!); // Remove a dica atual, se existir
      _currentTip = null;
    }
  }

  void _showTip() {
    // Verifica quais palavras ainda não foram acertadas
    final availableTips =
        _wordBoxes.where((wordBox) => !wordBox.isInitiallyCorrect).toList();

    if (_currentTip != null) {
      remove(_currentTip!);
      _currentTip = null;
    }

    if (availableTips.isNotEmpty) {
      final randomWordBox =
          availableTips[Random().nextInt(availableTips.length)];
      _currentTip = Tip(
        tip: randomWordBox.tip,
        screenSize: size,
      );
      add(_currentTip!); // Adiciona a dica ao jogo
      randomWordBox
          .waveAnimation(); // Chama a animação de onda para destacar o WordBox

      _stats.addTip(1);
      if (!_phaseHadTip) {
        _stats.addTipPhase(1);
        _phaseHadTip = true;
      }
    }
  }

  Future<void> _carregarPalavras() async {
    final random = Random();

    while (_currentWords.length < 4 && _usedWordIds.length < _allWords.length) {
      final randomWord = _allWords[random.nextInt(_allWords.length)];
      if (!_usedWordIds.contains(randomWord['id'])) {
        _usedWordIds.add(randomWord['id']);
        _currentWords.add(randomWord);
      }
    }

    _currentWords.sort((a, b) => (a['palavra'] as String)
        .length
        .compareTo((b['palavra'] as String).length));
  }

  Future<void> _montarTela() async {
    const double startX = 0;
    const double startY = 50;
    double offsetY = 0;
    for (var word in _currentWords) {
      final wordBox = WordBox(
          letterBoxes: List.generate(
              word['palavra'].length,
              (index) =>
                  LetterBox(position: Vector2.zero(), size: Vector2(50, 50))),
          correctWord: word['palavra'],
          audioButtonPosition: Vector2(startX, startY + offsetY),
          audioPath: word['audio'],
          spritePath: word['imagem'],
          onSolved: onWordSolved,
          onCorrect: onWordCorrect,
          onWrong: onWordWrong,
          onWrongLetterTap: onWrongLetterTap,
          tip: word['dica'],
          immediateCheckMode:
              properties["Dificuldade"] == 'Fácil' ? true : false);

      add(wordBox);
      _wordBoxes.add(wordBox);
      offsetY += 70;
    }

    if (_lettersContainer != null) {
      remove(_lettersContainer!);
      _lettersContainer = null;
    }

    _lettersContainer = LettersContainer(
      letters: _gerarLetrasUnicas(_currentWords),
      startPosition: Vector2(400, 100),
      wordBoxes: _wordBoxes,
      difficulty: properties["Dificuldade"] == 'Fácil' ? true : false,
    );
    add(_lettersContainer!);
  }

  /// Chamado sempre que uma palavra é completa (correta ou não)
  Future<void> _loadAndBuildLevel() async {
    await _carregarPalavras();
    await _montarTela();
    _startTipTimer();
  }

  Future<void> checkPalavrasCompletas() async {
    // bloqueia se já estamos trocando de fase
    if (_levelCompleted || _isTransitioning) return;

    if (!_wordBoxes.every((w) => w.isInitiallyCorrect)) return;

    _levelCompleted = true;
    _isTransitioning = true; // ← trava reentrâncias
    _stats.addPhaseTime(DateTime.now().difference(_phaseStartTime));

    if (_usedWordIds.length < _allWords.length) {
      await _prepareNextLevel();
    } else {
      await saveGameStats();
      pauseEngine();
      overlays.add('EndOverlay');
    }

    _isTransitioning = false; // fase nova pronta
    _levelCompleted = false; // libera para a próxima
  }

  /// Remove tudo do nível atual e cria o próximo
  Future<void> _prepareNextLevel() async {
    // 1) limpa fase anterior
    for (final box in _wordBoxes) {
      box.removeFromParent();
    }
    _wordBoxes.clear();
    _currentWords.clear();

    _lettersContainer?.removeFromParent();
    _lettersContainer = null;

    // 2) stats / timers
    _startNewPhase();

    // 3) espera um frame para garantir remoção
    await Future.delayed(const Duration(milliseconds: 50));

    // 4) carrega e constrói a nova fase
    await _loadAndBuildLevel();
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData = await _stats.toJson(idPatient, id);
    Map<String, dynamic> jsonDataFlag = _stats.toJsonFlag();
    Map<String, dynamic> jsonDataDescription = _stats.toJsonFlagDescription();

    JsonDataDao jsonDataDao = JsonDataDao();
    await jsonDataDao.insertJson(
        jsonData,
        idPatient,
        'Aventuras no Mundo das Palavras - Dificuldade: ${properties['Dificuldade']}',
        jsonDataFlag,
        jsonDataDescription);
  }

  List<String> _gerarLetrasUnicas(List<Map<String, dynamic>> words) {
    final uniqueLetters = <String>{};
    for (var word in words) {
      uniqueLetters.addAll((word['palavra'] as String).toUpperCase().split(''));
    }

    return uniqueLetters.toList()..shuffle(Random());
  }
}
