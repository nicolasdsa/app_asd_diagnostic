import 'package:app_asd_diagnostic/games/magic_words/components/audio_button.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:flame/components.dart';

class WordBox extends PositionComponent {
  final List<LetterBox> letterBoxes;
  final String correctWord;
  late final AudioButton audioButton;

  WordBox({
    required this.letterBoxes,
    required this.correctWord,
    required Vector2 audioButtonPosition,
    required String audioPath,
    required String spritePath,
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
    String constructedWord =
        letterBoxes.map((box) => box.currentLetter ?? '').join();
    print(constructedWord);
    print(correctWord);

    if (constructedWord.length == correctWord.length) {
      if (constructedWord.toLowerCase() == correctWord.toLowerCase()) {
        // Palavras são iguais, atualiza os sprites para a versão correta
        for (var box in letterBoxes) {
          if (!box.hasAnimated) {
            await box.setLetter(
                box.currentLetter!,
                await Sprite.load(
                    'words_adventure/letters/${box.currentLetter}_correct.png'));
            box.isLocked = true; // Trava a letra no LetterBox
            await box.wave(); // Animação de onda para indicar acerto
            box.hasAnimated = true; // Marca a animação como executada
          }
        }
        return true;
      } else {
        // Palavras têm o mesmo comprimento, mas são diferentes
        for (int i = 0; i < letterBoxes.length; i++) {
          if (letterBoxes[i].currentLetter != null &&
              !letterBoxes[i].hasAnimated) {
            await letterBoxes[i].setLetter(
                letterBoxes[i].currentLetter!,
                await Sprite.load(
                    'words_adventure/letters/${letterBoxes[i].currentLetter}_wrong.png'));
            await letterBoxes[i].shake(); // Animação de shake para indicar erro
            letterBoxes[i].hasAnimated =
                true; // Marca a animação como executada
          }
        }
        // Redefine os LetterBox após a animação de erro
        await Future.delayed(const Duration(milliseconds: 500), () {
          for (var box in letterBoxes) {
            box.reset();
          }
        });
      }
    }
    return false;
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
