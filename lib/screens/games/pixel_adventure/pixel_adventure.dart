import 'dart:async';
import 'dart:io';
import 'package:app_asd_diagnostic/screens/games/pixel_adventure/components/jump_button.dart';
import 'package:app_asd_diagnostic/screens/games/pixel_adventure/components/player.dart';
import 'package:app_asd_diagnostic/screens/games/pixel_adventure/components/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showControls = false;
  List<String> levelNames = ['Level-01.tmx', 'Level-02.tmx'];
  bool playSounds = true;
  double soundVolume = 1.0;
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();
    _loadLevel();

    if (Platform.isAndroid || Platform.isIOS) {
      showControls = true;
    }

    if (showControls) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
      add(JumpButton());
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
        knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
        background: SpriteComponent(
            sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
        margin: const EdgeInsets.only(left: 32, bottom: 32),
        priority: 9999);

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMoviment = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMoviment = 1;
        break;
      default:
        player.horizontalMoviment = 0;
        break;
    }
  }

  void loadNextLevel() async {
    if (currentLevelIndex < levelNames.length - 1) {
      remove(world);
      await world.removed;
      remove(cam);
      await cam.removed;
      currentLevelIndex++;
      _loadLevel();
    } else {
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() async {
    Level world =
        Level(player: player, levelName: levelNames[currentLevelIndex]);

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
