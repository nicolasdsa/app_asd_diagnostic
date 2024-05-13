import 'dart:async';

import 'package:app_asd_diagnostic/screens/games/gift_grab/components/background_component.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/components/gift_component.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/components/globals.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/components/ice_component.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/components/joystick.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/components/santa_component.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/screens/game_play.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class GiftGrabGame extends FlameGame with DragCallbacks, HasCollisionDetection {
  int score = 0;

  late Timer _timer;

  int _remainingTime = 30;

  late TextComponent _scoreText;

  late TextComponent _timeText;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    addMenu(menu: Menu.main);
    pauseEngine();

    add(BackgroundComponent());
    add(SantaComponent(joystick: joystick));
    add(GiftComponent());
    add(joystick);

    FlameAudio.audioCache.loadAll([Globals.itemGrabSound]);

    add(ScreenHitbox());

    add(IceComponent(startPosition: Vector2(200, 200)));
    add(IceComponent(startPosition: Vector2(size.x - 200, size.y - 200)));

    _scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(40, 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 30.0,
        ),
      ),
    );

    add(_scoreText);

    _timeText = TextComponent(
      text: 'Timer: $_remainingTime secs',
      position: Vector2(size.x - 200, 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 30.0,
        ),
      ),
    );

    add(_timeText);

    _timer = Timer(1, repeat: true, onTick: () {
      if (_remainingTime == 0) {
        pauseEngine();
        addMenu(menu: Menu.gameOver);
      } else {
        _remainingTime -= 1;
      }
    });

    _timer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
    _scoreText.text = 'Score: $score';
    _timeText.text = 'Timer: $_remainingTime secs';
  }

  void reset() {
    score = 0;
    _remainingTime = 30;
  }

  void addMenu({required Menu menu}) {
    overlays.add(menu.name);
  }

  void removeMenu({required Menu menu}) {
    overlays.remove(menu.name);
  }
}
