import 'dart:math';

import 'package:app_asd_diagnostic/games/gift_grab/components/globals.dart';
import 'package:app_asd_diagnostic/games/gift_grab/components/santa_component.dart';
import 'package:app_asd_diagnostic/games/gift_grab/gift_grab.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class GiftComponent extends SpriteComponent
    with HasGameRef<GiftGrabGame>, CollisionCallbacks {
  /// Height of the sprite.
  final double _spriteHeight = Globals.isTablet ? 200.0 : 100.0;

  /// Used for generating random position of gift.
  final Random _random = Random();

  GiftComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite(Globals.giftSprite);

    position = _createRandomPosition();

    width = _spriteHeight;
    height = _spriteHeight;

    anchor = Anchor.center;

    add(CircleHitbox()..radius = 1);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is SantaComponent) {
      FlameAudio.play(Globals.itemGrabSound);

      removeFromParent();

      gameRef.score += 1;

      gameRef.add(GiftComponent());
    }
  }

  /// Create new position for the gift on random.
  Vector2 _createRandomPosition() {
    final double x = _random.nextInt(gameRef.size.x.toInt()).toDouble();
    final double y = _random.nextInt(gameRef.size.y.toInt()).toDouble();

    return Vector2(x, y);
  }
}
