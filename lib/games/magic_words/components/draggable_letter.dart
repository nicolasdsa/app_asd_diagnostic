import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';

class DraggableLetter extends SpriteComponent
    with DragCallbacks, CollisionCallbacks {
  final String letter; // A letra representada por este componente
  final Sprite letterSprite; // Sprite correspondente à letra
  bool isDragging = false;
  Vector2 initialPosition;
  LetterBox? collidedLetterBox;

  DraggableLetter({
    required this.letter,
    required this.letterSprite,
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
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.add(event
        .localDelta); // Atualiza a posição do sprite com base no movimento do toque
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;
    if (collidedLetterBox != null) {
      collidedLetterBox!
          .setLetter(letter, letterSprite); // Atualiza o LetterBox
    }
    position = initialPosition.clone(); // Reseta a posição para a inicial
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is LetterBox) {
      collidedLetterBox = other; // Armazena a caixa de letra colidida
    }
    super.onCollision(intersectionPoints, other);
  }
}
