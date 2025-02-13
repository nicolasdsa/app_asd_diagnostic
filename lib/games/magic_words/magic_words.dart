import 'package:app_asd_diagnostic/games/magic_words/components/background.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/cloud.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letters_container.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/tip.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/word_box.dart';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:app_asd_diagnostic/db/words_dao.dart';
import 'dart:math';
import 'dart:async';

class JogoFormaPalavrasGame extends FlameGame with HasCollisionDetection {
  final WordsDao _wordsDao = WordsDao();
  final Set<int> _usedWordIds = {};
  final List<Map<String, dynamic>> _currentWords = [];
  final List<WordBox> _wordBoxes = [];
  LettersContainer? _lettersContainer;
  bool _levelCompleted = false;

  Timer? _tipTimer; // Timer para exibir dicas
  Tip? _currentTip;

  @override
  Future<void> onLoad() async {
    await Future.delayed(Duration.zero); // Aguarda o tamanho correto da tela
    camera.viewport = FixedResolutionViewport(
        resolution: Vector2(canvasSize.x, canvasSize.y));

    await add(Background());
    await add(Cloud());
    await _carregarPalavras();
    await _montarTela();
    _startTipTimer();
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
    }
  }

  Future<void> _carregarPalavras() async {
    final allWords = await _wordsDao.getWords();
    final random = Random();

    while (_currentWords.length < 4 && _usedWordIds.length < allWords.length) {
      final randomWord = allWords[random.nextInt(allWords.length)];
      if (!_usedWordIds.contains(randomWord['id'])) {
        _usedWordIds.add(randomWord['id']);
        _currentWords.add(randomWord);
      }
    }
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
          tip: word['dica']);

      add(wordBox);
      _wordBoxes.add(wordBox);
      offsetY += 70;
    }

    if (_lettersContainer != null) {
      remove(_lettersContainer!);
    }

    _lettersContainer = LettersContainer(
      letters: _gerarLetrasUnicas(_currentWords),
      startPosition: Vector2(400, 100),
      wordBoxes: _wordBoxes,
    );
    add(_lettersContainer!);
  }

  Future<void> checkPalavrasCompletas() async {
    final allCorrect =
        _wordBoxes.every((wordBox) => wordBox.isInitiallyCorrect);

    if (allCorrect) {
      _levelCompleted = true;
      _usedWordIds.clear();
      _currentWords.clear();
      _wordBoxes.clear();
      await _carregarPalavras();
      await _montarTela();
      _resetTipTimer(); // Reinicia o timer ao carregar o próximo nível
    }
  }

  List<String> _gerarLetrasUnicas(List<Map<String, dynamic>> words) {
    final uniqueLetters = <String>{};
    for (var word in words) {
      uniqueLetters.addAll((word['palavra'] as String).toUpperCase().split(''));
    }
    return uniqueLetters.toList();
  }
}
