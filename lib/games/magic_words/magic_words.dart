import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letters_container.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/word_box.dart';
import 'package:flame/game.dart';
import 'package:app_asd_diagnostic/db/words_dao.dart';
import 'dart:math';

class JogoFormaPalavrasGame extends FlameGame with HasCollisionDetection {
  final WordsDao _wordsDao = WordsDao();
  final Set<int> _usedWordIds = {};
  final List<Map<String, dynamic>> _currentWords = [];
  final List<WordBox> _wordBoxes = [];
  bool _levelCompleted = false; // Adicione esta variável

  @override
  Future<void> onLoad() async {
    await _carregarPalavras();
    await _montarTela();
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
    const double startX = 50;
    const double startY = 100;
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
      );

      add(wordBox);
      _wordBoxes.add(wordBox); // Adicione a wordBox à lista
      offsetY += 100; // Espaçamento entre as palavras
    }

    final lettersContainer = LettersContainer(
      letters: _gerarLetrasEmbaralhadas(_currentWords),
      startPosition: Vector2(400, 200),
    );
    add(lettersContainer);
  }

  void _checkPalavrasCompletas() {
    if (_levelCompleted) return; // Verifique se o nível já foi completado

    final allCorrect = _wordBoxes.every((wordBox) => wordBox.checkWord());
    if (allCorrect) {
      _levelCompleted = true; // Marque o nível como completado
      _usedWordIds.clear(); // Limpa o histórico para o novo nível
      _currentWords.clear();
      _wordBoxes.clear();
      _carregarPalavras().then((_) => _montarTela());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _checkPalavrasCompletas();
  }

  List<String> _gerarLetrasEmbaralhadas(List<Map<String, dynamic>> words) {
    final List<String> allLetters = words
        .expand((word) => word['palavra'].toUpperCase().split(''))
        .cast<String>()
        .toList();
    allLetters.shuffle();
    return allLetters;
  }
}
