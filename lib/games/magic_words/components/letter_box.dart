import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';

class LetterBox extends SpriteComponent with TapCallbacks, CollisionCallbacks {
  String? currentLetter; // Letra atualmente armazenada na caixa
  final String defaultSpritePath =
      'words_adventure/icons/hex_white.png'; // Sprite inicial
  late final Sprite defaultSprite;

  LetterBox({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    defaultSprite = await Sprite.load(defaultSpritePath);
    sprite = defaultSprite; // Define o sprite inicial

    // Adiciona um hitbox para detectar colisões
    add(RectangleHitbox());
  }

  void setLetter(String letter, Sprite letterSprite) {
    currentLetter = letter;
    sprite = letterSprite;
    // Adicione um print para debug
    print('Letra definida: $letter');
  }

  @override
  bool onTapDown(TapDownEvent event) {
    // Reseta para o sprite padrão quando clicado
    currentLetter = null;
    sprite = defaultSprite;
    return true;
  }
}
