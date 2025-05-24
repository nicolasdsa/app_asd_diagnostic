import 'package:app_asd_diagnostic/games/my_routine/components/objetive_manager.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/objetives_hud.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/level.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/player.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame
    with HasCollisionDetection, WidgetsBindingObserver {
  late Player player;
  late JoystickComponent joystick;
  late CameraComponent cam;
  late ButtonComponent actionButton;
  late ObjectiveManager objectives;
  AudioPlayer? _audioPlayer;
  String? currentPhaseText;
  List<String>? currentIconNames;
  List<String>? currentCorrectIcons;
  String? currentStageId;
  bool currentImmediateFeedback = false;

  List<String> musicTracks = [
    'music_1.mp3',
    'music_2.mp3',
    'music_3.mp3',
    'music_4.mp3',
    'music_5.mp3',
    'music_6.mp3',
    'music_7.mp3',
    'music_8.mp3',
    'music_9.mp3',
    'music_10.mp3',
    'music_11.mp3',
  ];
  int currentTrackIndex = 0;

  @override
  Future<void> onLoad() async {
    WidgetsBinding.instance.addObserver(this);
    musicTracks.shuffle();
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerComplete.listen((event) {
      _onMusicComplete(); // Função chamada ao terminar a música
    });
    _playNextMusic();
    //debugMode = true;

    objectives = ObjectiveManager()..priority = 50;
    objectives.registerObjective("Escovar os dentes");
    objectives.registerObjective("Hora do lanche");

    add(objectives);

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.zoom = 0.1;

    joystick = JoystickComponent(
      knob:
          CircleComponent(radius: 15, paint: Paint()..color = Colors.blueGrey),
      background: CircleComponent(
          radius: 50, paint: Paint()..color = Colors.grey.withOpacity(0.5)),
      margin: const EdgeInsets.only(left: 20, bottom: 20),
      priority: 100,
    );

    actionButton = ButtonComponent(
      button: CircleComponent(
          radius: 20, paint: Paint()..color = Colors.green.withOpacity(0.7)),
      buttonDown: CircleComponent(
          radius: 20, paint: Paint()..color = Colors.green.withOpacity(0.5)),
      priority: 100,
    );

    // Define a posição do botão de ação no lado inferior direito da tela
    actionButton.position = Vector2(
      size.x - actionButton.size.x - 20, // 20 é a margem da direita
      size.y - actionButton.size.y - 20, // 20 é a margem de baixo
    );

    add(joystick);
    add(actionButton);
    add(ObjectivesHud()..priority = 1000);

    player = Player(joystick: joystick, actionButton: actionButton);
    player.priority = 999;

    await _loadLevel();
  }

  Future<void> _loadLevel() async {
    Level world = Level(
      levelName: "my_routine/map-3.tmx",
      player: player,
    );
    cam = CameraComponent(
      world: world,
    );
    cam.follow(player);
    cam.viewfinder.zoom = 1.5;
    cam.priority = 2;

    addAll([cam, world]);
  }

  void _playNextMusic() {
    _audioPlayer?.play(
        AssetSource('audio/my_routine/${musicTracks[currentTrackIndex]}'),
        volume: 0.20);
  }

  void _onMusicComplete() {
    currentTrackIndex++;
    if (currentTrackIndex >= musicTracks.length) {
      musicTracks.shuffle();
      currentTrackIndex = 0;
    }
    _playNextMusic();
  }

  // Método que lida com as mudanças de estado do ciclo de vida do app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer?.pause(); // Pausa a música ao minimizar o app
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer
          ?.resume(); // Retoma a música quando o app volta, se o jogo não estiver pausado
    }
  }
}
