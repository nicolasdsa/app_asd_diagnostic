import 'package:app_asd_diagnostic/games/magic_words/components/audio_button.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:flame/components.dart';

class WordBox extends PositionComponent {
  final List<LetterBox> letterBoxes;
  final String correctWord;
  late final AudioButton audioButton;
  bool isInitiallyCorrect;

  WordBox({
    required this.letterBoxes,
    required this.correctWord,
    required Vector2 audioButtonPosition,
    required String audioPath,
    required String spritePath,
    this.isInitiallyCorrect = false,
  }) {
    // Adiciona o botão de áudio
    audioButton = AudioButton(
      position: audioButtonPosition,
      audioPath: audioPath,
      spritePath: spritePath,
    );
    add(audioButton);

    // Calcula a posição inicial das LetterBox relativa ao botão de áudio
    final initialLetterBoxX =
        audioButtonPosition.x + 70; // Ajuste de 70 pixels ao lado
    final initialLetterBoxY = audioButtonPosition.y;

    // Posiciona as LetterBox corretamente ao lado do botão
    for (int i = 0; i < letterBoxes.length; i++) {
      letterBoxes[i].position =
          Vector2(initialLetterBoxX + (i * 60), initialLetterBoxY);
      add(letterBoxes[i]);
    }
  }

  Future<bool> checkWord() async {
    if (!areAllFilled()) {
      return false;
    }

    String constructedWord =
        letterBoxes.map((box) => box.currentLetter ?? '').join();
    print(constructedWord);
    print(correctWord);

    if (constructedWord.length == correctWord.length) {
      if (constructedWord.toLowerCase() == correctWord.toLowerCase() &&
          !isInitiallyCorrect) {
        // Palavras são iguais, atualiza os sprites para a versão correta
        for (var box in letterBoxes) {
          await box.setLetter(
              box.currentLetter!,
              await Sprite.load(
                  'words_adventure/letters/${box.currentLetter}_correct.png'));
          box.isLocked = true; // Trava a letra no LetterBox
        }
        isInitiallyCorrect = true;
        _waveAnimation(); // Animação de onda para indicar acerto
        return true;
      } else {
        // Palavras têm o mesmo comprimento, mas são diferentes
        for (int i = 0; i < letterBoxes.length; i++) {
          await letterBoxes[i].setLetter(
              letterBoxes[i].currentLetter!,
              await Sprite.load(
                  'words_adventure/letters/${letterBoxes[i].currentLetter}_wrong.png'));
        }
        _shakeAnimation(); // Animação de shake para indicar erro
        // Redefine os LetterBox após a animação de erro
        Future.delayed(const Duration(milliseconds: 500), () {
          for (var box in letterBoxes) {
            box.reset();
          }
        });
      }
    }
    return false;
  }

  void _waveAnimation() async {
    const double waveHeight = 5.0; // Diminui a amplitude do movimento de onda
    const int waveDuration = 50;

    for (int i = 0; i < 3; i++) {
      for (var box in letterBoxes) {
        box.position.add(Vector2(0, -waveHeight));
      }
      await Future.delayed(const Duration(milliseconds: waveDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(0, waveHeight * 2));
      }
      await Future.delayed(const Duration(milliseconds: waveDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(0, -waveHeight));
      }
      await Future.delayed(const Duration(milliseconds: waveDuration));
    }
  }

  void _shakeAnimation() async {
    const double shakeDistance = 5.0;
    const int shakeDuration = 50;

    for (int i = 0; i < 3; i++) {
      for (var box in letterBoxes) {
        box.position.add(Vector2(shakeDistance, 0));
      }
      await Future.delayed(Duration(milliseconds: shakeDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(-shakeDistance * 2, 0));
      }
      await Future.delayed(Duration(milliseconds: shakeDuration));
      for (var box in letterBoxes) {
        box.position.add(Vector2(shakeDistance, 0));
      }
      await Future.delayed(Duration(milliseconds: shakeDuration));
    }
  }

  bool isLetterInCorrectPosition(int index, String letter) {
    return correctWord[index] == letter;
  }

  bool areAllFilled() {
    return letterBoxes.every((box) => box.currentLetter != null);
  }

  void resetWord() {
    for (var box in letterBoxes) {
      box.reset();
    }
  }
}
