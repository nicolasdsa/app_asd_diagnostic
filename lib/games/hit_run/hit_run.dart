import 'dart:async';

import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/shape.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class HitRun extends FlameGame with TapCallbacks, HasCollisionDetection {
  List<String> levelNames = ['sem título.tmx'];
  int currentLevelIndex = 0;
  late CameraComponent cam;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();
    //debugMode = true;

    return super.onLoad();
  }

  void _loadLevel() async {
    Level world = Level(levelName: levelNames[currentLevelIndex]);

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([cam, world]);
  }
}
