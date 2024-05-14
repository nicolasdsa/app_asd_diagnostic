import 'dart:async';

import 'package:app_asd_diagnostic/games/gift_grab/components/globals.dart';
import 'package:app_asd_diagnostic/games/gift_grab/components/ice_component.dart';
import 'package:app_asd_diagnostic/games/gift_grab/gift_grab.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

enum MovementState { idle, slideLeft, slideRight, frozen }

class SantaComponent extends SpriteGroupComponent
    with HasGameRef<GiftGrabGame>, CollisionCallbacks {
  SantaComponent({required this.joystick});
  final JoystickComponent joystick;

  /// Screen boundries.
  late double _rightBound;
  late double _leftBound;
  late double _upBound;
  late double _downBound;
  final double _spriteHeight = Globals.isTablet ? 200.0 : 100;

  bool _frozen = false;
  final Timer _timer = Timer(3);

  /// Max speed of sliding santa.
  static final double _originalSpeed = Globals.isTablet ? 500.0 : 250.0;
  static final double _speed = _originalSpeed;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    Sprite santaIdle = await gameRef.loadSprite(Globals.santaIdle);
    Sprite santaSlideLeft =
        await gameRef.loadSprite(Globals.santaSlideLeftSprite);
    Sprite santaSlideRight =
        await gameRef.loadSprite(Globals.santaSlideRightSprite);
    Sprite santaFrozen = await gameRef.loadSprite(Globals.santaFrozen);

    sprites = {
      MovementState.idle: santaIdle,
      MovementState.slideLeft: santaSlideLeft,
      MovementState.slideRight: santaSlideRight,
      MovementState.frozen: santaFrozen,
    };

    _rightBound = gameRef.size.x - 45;
    _leftBound = 45;
    _upBound = 55;
    _downBound = gameRef.size.y - 85;

    current = MovementState.idle;

    position = gameRef.size / 2;
    height = _spriteHeight;
    width = _spriteHeight * 1.42;
    anchor = Anchor.center;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_frozen) {
      if (joystick.direction == JoystickDirection.idle) {
        current = MovementState.idle;
        return;
      }

      // If player is exiting right screen
      if (x >= _rightBound) {
        x = _rightBound - 1;
      }

      // If player is exiting left screen
      if (x <= _leftBound) {
        x = _leftBound + 1;
      }

      // If player is exiting down screen
      if (y >= _downBound) {
        y = _downBound - 1;
      }

      // If player is exiting up screen
      if (y <= _upBound) {
        y = _upBound + 1;
      }

      bool movingLeft = joystick.relativeDelta[0] < 0;

      if (movingLeft) {
        current = MovementState.slideLeft;
      } else {
        current = MovementState.slideRight;
      }

      // Update position.
      position.add(joystick.relativeDelta * dt * _speed);
    } else {
      _timer.update(dt);
      if (_timer.finished) {
        _unfreezeSanta();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is IceComponent) {
      _freezeSanta();
    }
  }

  /// Freeze Santa.
  void _freezeSanta() {
    if (!_frozen) {
      _frozen = true;
      FlameAudio.play(Globals.freezeSound);
      current = MovementState.frozen;
      _timer.start();
    }
  }

  void _unfreezeSanta() {
    _frozen = false;

    current = MovementState.idle;
  }
}
