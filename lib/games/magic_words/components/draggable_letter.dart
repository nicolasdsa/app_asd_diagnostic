import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/word_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/magic_words.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';

class DraggableLetter extends SpriteComponent
    with DragCallbacks, CollisionCallbacks, HasGameRef<JogoFormaPalavrasGame> {
  final String letter; // A letra representada por este componente
  final Sprite letterSprite; // Sprite correspondente à letra
  final List<WordBox> wordBoxes; // Lista de WordBox
  bool isDragging = false;
  Vector2 initialPosition;
  LetterBox? collidedLetterBox;
  WordBox? collidedWordBox;

  DraggableLetter({
    required this.letter,
    required this.letterSprite,
    required this.wordBoxes, // Adicione a lista de WordBox ao construtor
    required Vector2 position,
    required Vector2 size,
  })  : initialPosition = position.clone(),
        super(position: position, size: size, sprite: letterSprite);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Adiciona um hitbox para detectar colisões
    add(RectangleHitbox());
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
    collidedLetterBox = null; // Reseta a caixa de letra colidida
    collidedWordBox = null; // Reseta o WordBox colidido
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.add(event
        .localDelta); // Atualiza a posição do sprite com base no movimento do toque
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);
    isDragging = false;

    if (collidedLetterBox != null && collidedWordBox != null) {
      // **Novo**: se já está “locked”, não faz nada
      if (collidedLetterBox!.isLocked) {
        position = initialPosition.clone();
        return;
      }

      // restante do fluxo de inserção...
      await collidedLetterBox!.setLetter(letter, letterSprite);
      final wordBox = collidedWordBox!;
      final idx = wordBox.letterBoxes.indexOf(collidedLetterBox!);

      if (wordBox.immediateCheckMode) {
        await wordBox.checkLetterAt(idx);
      } else {
        await wordBox.checkWord();
      }

      // **Mover aqui**: chama sempre a checagem de fim de fase
      gameRef.checkPalavrasCompletas();
    }

    position = initialPosition.clone();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is LetterBox) {
      collidedLetterBox = other; // Armazena a caixa de letra colidida
      // Encontra o WordBox ao qual o LetterBox pertence
      collidedWordBox = wordBoxes
          .firstWhere((wordBox) => wordBox.letterBoxes.contains(other));
    }
  }
}
