import 'package:app_asd_diagnostic/games/magic_words/components/draggable_letter.dart';
import 'package:flame/components.dart';

class LettersContainer extends PositionComponent {
  LettersContainer(
      {required List<String> letters, required Vector2 startPosition}) {
    double offsetX = 0;
    double offsetY = 0;
    const double maxLettersPerRow = 5;

    // Use um Set para garantir que apenas letras únicas sejam usadas
    final uniqueLetters = letters.toSet().toList();

    for (int i = 0; i < uniqueLetters.length; i++) {
      // Quando atinge o máximo de letras na linha, quebra para a próxima linha
      if (i % maxLettersPerRow == 0 && i != 0) {
        offsetX = 0; // Reseta o deslocamento horizontal
        offsetY += 70; // Move para a próxima linha
      }

      _createDraggableLetter(
          uniqueLetters[i], startPosition + Vector2(offsetX, offsetY));
      offsetX += 60; // Espaçamento entre as letras
    }
  }

  Future<void> _createDraggableLetter(String letter, Vector2 position) async {
    final sprite = await Sprite.load(
        'words_adventure/letters/$letter.png'); // Carrega o sprite correspondente à letra
    final draggableLetter = DraggableLetter(
      letter: letter,
      letterSprite: sprite,
      position: position,
      size: Vector2(50, 50),
    );
    add(draggableLetter);
  }
}
