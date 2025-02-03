import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioButton extends SpriteComponent with TapCallbacks {
  final String audioPath;
  final String spritePath;

  AudioButton(
      {required Vector2 position,
      required this.audioPath,
      required this.spritePath})
      : super(position: position, size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite =
        await Sprite.load(spritePath); // Carrega o sprite da imagem da palavra
  }

  @override
  bool onTapDown(TapDownEvent event) {
    FlameAudio.play(audioPath); // Toca o áudio da palavra
    return false;
  }
}
