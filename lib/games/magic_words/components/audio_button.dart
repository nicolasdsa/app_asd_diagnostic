import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart'; // já vem como dependência do Flame Audio

class AudioButton extends SpriteComponent with TapCallbacks {
  final String audioPath;
  final String spritePath;

  // **Mantém referência global ao player que estiver tocando**
  static AudioPlayer? _currentPlayer;

  AudioButton({
    required Vector2 position,
    required this.audioPath,
    required this.spritePath,
  }) : super(position: position, size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(spritePath);
  }

  // --------- LÓGICA EXCLUSIVA-POR-VEZ ---------
  Future<void> _playExclusive() async {
    // Se já existe um áudio tocando, interrompe-o
    if (_currentPlayer != null) {
      await _currentPlayer!.stop();
      _currentPlayer = null;
    }

    // Inicia o novo áudio e guarda a referência
    final player = await FlameAudio.play(audioPath);
    _currentPlayer = player;

    // Quando o áudio terminar, libera a referência
    player.onPlayerComplete.listen((event) {
      if (_currentPlayer == player) _currentPlayer = null;
    });
  }

  @override
  bool onTapDown(TapDownEvent event) {
    _playExclusive(); // chama sem await – não bloqueia o tap
    return false; // mantém comportamento original
  }
}
