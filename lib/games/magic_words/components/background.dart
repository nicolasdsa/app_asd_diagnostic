import 'package:app_asd_diagnostic/games/magic_words/magic_words.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

class Background extends ParallaxComponent {
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('words_adventure/background/Fundo.png'),
        ParallaxImageData('words_adventure/background/Grama.png'),
      ],
      baseVelocity: Vector2(0, 0),
      fill: LayerFill.width, // Estica as imagens para cobrir toda a largura
      size: game.size, // Garante que o fundo cubra toda a tela
    );
  }
}
