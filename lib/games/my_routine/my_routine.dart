import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/level.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/player.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  late CameraComponent cam;
  late ButtonComponent actionButton;

  @override
  Future<void> onLoad() async {
    debugMode = true;

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

    player = Player(joystick: joystick, actionButton: actionButton);
    player.priority = 999;

    await _loadLevel();
  }

  Future<void> _loadLevel() async {
    Level world = Level(
      levelName: "map-3.tmx",
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
}
