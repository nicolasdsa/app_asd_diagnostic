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

  bool checkWord() {
    String constructedWord =
        letterBoxes.map((box) => box.currentLetter ?? '').join();
    return constructedWord == correctWord;
  }

  bool areAllFilled() {
    return letterBoxes.every((box) => box.currentLetter != null);
  }

  void resetWord() {
    for (var box in letterBoxes) {
      box.sprite = box.defaultSprite;
      box.currentLetter = null;
    }
  }
}
