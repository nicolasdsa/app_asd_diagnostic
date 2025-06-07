import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/objetive_manager.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/objetives_hud.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/level.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/player.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/game_stats.dart';

class MyRoutine extends FlameGame
    with HasCollisionDetection, WidgetsBindingObserver, TapCallbacks {
  late Player player;
  late JoystickComponent joystick;
  late CameraComponent cam;
  late ButtonComponent actionButton;
  late ObjectiveManager objectives;
  DateTime? gameStartTime;
  AudioPlayer? _audioPlayer;
  String? currentPhaseText;
  List<String>? currentIconNames;
  List<String>? currentCorrectIcons;
  String? currentStageId;
  late bool currentImmediateFeedback;
  GameStats stats = GameStats();

  MyRoutine({
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;
  bool _endScreenShown = false;

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
    currentImmediateFeedback =
        properties["Dificuldade"] == 'Fácil' ? true : false;
    gameStartTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    musicTracks.shuffle();
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerComplete.listen((event) {
      _onMusicComplete();
    });
    _playNextMusic();
    //debugMode = true;

    objectives = ObjectiveManager()..priority = 50;
    objectives.registerObjective("Acordar");
    objectives.registerObjective("Escovar os dentes");
    objectives.registerObjective("Ir para escola");
    objectives.registerObjective("Tomar banho");
    objectives.registerObjective("Hora de comer");
    objectives.registerObjective("Hora de brincar");
    objectives.registerObjective("Hora de dormir");

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
    actionButton.position = Vector2(
      size.x - actionButton.size.x - 20,
      size.y - actionButton.size.y - 20,
    );

    add(joystick);
    add(actionButton);
    add(ObjectivesHud()..priority = 1000);

    player = Player(joystick: joystick, actionButton: actionButton);
    player.priority = 999;

    await _loadLevel();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Verifica se concluiu todos os objetivos
    if (!_endScreenShown && objectives.all.every((e) => e.value)) {
      _showEndScreen();
    }
  }

  @override
  bool onTapDown(TapDownEvent info) {
    // Se estiver na tela de fim, qualquer toque leva ao menu
    if (_endScreenShown) {
      returnToMainMenu();
      return true;
    }
    return false;
  }

  void _showEndScreen() {
    _endScreenShown = true;
    saveGameStats();
    _audioPlayer?.stop();
    pauseEngine();
    overlays.add('EndOverlay');
    // Exibe a tela de fim do dia
  }

  void returnToMainMenu() {
    // Certifica-se que a música está parada
    _audioPlayer?.stop();
    // Navegue para o menu inicial
    // Exemplo usando Navigator (se envolver GameWidget em MaterialApp):
    if (buildContext != null) {
      Navigator.of(buildContext!).pushReplacementNamed(
        '/dailyRoutineMenu',
        arguments: {
          'id': id, // Substitua pelo valor real de id
          'idPatient': idPatient, // Substitua pelo valor real de idPatient
          'properties': properties, // Substitua pelo mapa real de propriedades
        },
      );
    }
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
      volume: 0.20,
    );
  }

  void _onMusicComplete() {
    currentTrackIndex++;
    if (currentTrackIndex >= musicTracks.length) {
      musicTracks.shuffle();
      currentTrackIndex = 0;
    }
    _playNextMusic();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer?.resume();
    }
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData = await stats.toJson(idPatient, id);
    Map<String, dynamic> jsonDataFlag = stats.toJsonFlag();
    Map<String, dynamic> jsonDataDescription = stats.toJsonFlagDescription();

    JsonDataDao jsonDataDao = JsonDataDao();
    await jsonDataDao.insertJson(
        jsonData,
        idPatient,
        'Meu Dia a Dia - Dificuldade: ${properties['Dificuldade']}',
        jsonDataFlag,
        jsonDataDescription);
  }
}
