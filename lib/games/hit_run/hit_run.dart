import 'dart:async';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/game_stats.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class HitRun extends FlameGame with TapCallbacks, HasCollisionDetection {
  final String idPatient;
  final String difficulty;
  final String mode;

  HitRun(
      {required this.idPatient, required this.difficulty, required this.mode});

  GameStats stats = GameStats();
  List<String> levelNames = ['easy.tmx', 'hard.tmx', 'easy-no-sound.tmx'];
  late CameraComponent cam;
  late Level _level; // Atributo privado

  Level get level => _level;

  @override
  FutureOr<void> onLoad() async {
    stats.startGame();
    await images.loadAllImages();
    _loadLevel();
    print('ID do Paciente: $idPatient'); // Imprime o idPatient
    print(
        'Nível de dificuldade: $difficulty'); // Imprime o nível de dificuldade
    print('Modo: $mode'); // Imprime o modo
    return super.onLoad();
  }

  void resetGame() {
    saveGameStats();
    stats.endGame();
    stats.startGame();
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData = stats.toJson();
    print('JSON data before saving: $jsonData');
    JsonDataDao jsonDataDao = JsonDataDao();
    await jsonDataDao.insertJson(jsonData, idPatient, 'Hit run');
  }

  void _loadLevel() async {
    if (mode == 'sonoro') {
      levelNames = ['easy.tmx', 'hard.tmx'];
    }

    if (mode == 'visual') {
      levelNames = ['easy-no-sound.tmx', 'hard-no-sound.tmx'];
    }

    int currentLevelIndex = difficulty == 'easy' ? 0 : 1;
    List<String> colors = ['blue', 'green', 'pink', 'yellow'];
    int flagMode = mode == 'visual' ? 0 : 1;

    if (currentLevelIndex == 0) {
      colors.shuffle();
      colors = [colors[0], colors[0]];
    }

    if (currentLevelIndex == 1) {
      colors.shuffle();
      colors = colors.take(2).toList();
    }

    _level = Level(
        levelName: levelNames[currentLevelIndex],
        colors: colors,
        mode: flagMode); // Inicializa _level

    cam = CameraComponent.withFixedResolution(
      world: _level,
      width: 640,
      height: 400,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([cam, _level]);
  }
}
