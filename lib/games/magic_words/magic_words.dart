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
  LettersContainer?
      _lettersContainer; // Adicione uma referência ao LettersContainer
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
      );

      add(wordBox);
      _wordBoxes.add(wordBox); // Adicione a wordBox à lista
      offsetY += 70; // Espaçamento entre as palavras
    }

    // Remova o LettersContainer anterior, se existir
    if (_lettersContainer != null) {
      remove(_lettersContainer!);
    }

    // Crie e adicione um novo LettersContainer
    _lettersContainer = LettersContainer(
      letters: _gerarLetrasUnicas(_currentWords),
      startPosition: Vector2(400, 100),
      wordBoxes: _wordBoxes, // Passe a lista de WordBox
    );
    add(_lettersContainer!);
  }

  Future<void> checkPalavrasCompletas() async {
    //if (_levelCompleted) return; // Verifique se o nível já foi completado

    final allCorrect =
        _wordBoxes.every((wordBox) => wordBox.isInitiallyCorrect);

    if (allCorrect) {
      _levelCompleted = true; // Marque o nível como completado
      _usedWordIds.clear(); // Limpa o histórico para o novo nível
      _currentWords.clear();
      _wordBoxes.clear();
      await _carregarPalavras();
      await _montarTela();
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
