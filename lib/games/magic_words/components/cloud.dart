import 'package:flame/components.dart';

class Cloud extends SpriteComponent with HasGameRef {
  Cloud()
      : super(size: Vector2(100, 50)); // Ajuste o tamanho conforme necessário

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('words_adventure/background/Nuvem.png');
    position = Vector2(0, 50); // Posição inicial da nuvem
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += 100 * dt; // Velocidade da nuvem

    // Reinicia a posição da nuvem quando ela sai da tela
    if (position.x > gameRef.size.x) {
      position.x = -size.x;
    }
  }
}
