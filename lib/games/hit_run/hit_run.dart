import 'dart:async';

import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class HitRun extends FlameGame with TapCallbacks, HasCollisionDetection {
  List<String> levelNames = ['sem título.tmx'];
  int currentLevelIndex = 0;
  late CameraComponent cam;
  late Level _level; // Adiciona a propriedade _level

  Level get level => _level; // Adiciona o getter para level

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();
    return super.onLoad();
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
