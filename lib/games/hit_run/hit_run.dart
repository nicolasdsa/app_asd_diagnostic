import 'dart:async';

import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/game_stats.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class HitRun extends FlameGame with TapCallbacks, HasCollisionDetection {
  final String idPatient;

  HitRun({required this.idPatient});

  GameStats stats = GameStats();
  List<String> levelNames = ['sem título.tmx'];
  int currentLevelIndex = 0;
  late CameraComponent cam;
  late Level _level; // Atributo privado

  Level get level => _level;

  @override
  FutureOr<void> onLoad() async {
    stats.startGame();
    await images.loadAllImages();
    _loadLevel();
    print('ID do Paciente: $idPatient'); // Imprime o idPatient
    return super.onLoad();
  }

  void resetGame() {
    saveGameStats();
    stats.endGame();
    stats.startGame();
  }

  @override
  void onRemove() {
    print('alo TA SAINDO');
    saveGameStats();
    super.onRemove();
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData = stats.toJson();
    print('JSON data before saving: $jsonData');
    JsonDataDao jsonDataDao = JsonDataDao();
    await jsonDataDao.insertJson(jsonData);
  }

  void _loadLevel() async {
    _level =
        Level(levelName: levelNames[currentLevelIndex]); // Inicializa _level

    cam = CameraComponent.withFixedResolution(
      world: _level,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([cam, _level]);
  }
}
