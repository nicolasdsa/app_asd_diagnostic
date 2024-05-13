import 'dart:async';

import 'package:app_asd_diagnostic/screens/games/pixel_adventure/components/player.dart';
import 'package:app_asd_diagnostic/screens/games/pixel_adventure/pixel_adventure.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  bool reachedCheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
        position: Vector2(18, 27),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(64, 64),
        ));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedCheckpoint();
    }
    super.onCollision(intersectionPoints, other);
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
        SpriteAnimationData.sequenced(
            amount: 25,
            stepTime: 0.05,
            textureSize: Vector2(64, 64),
            loop: false));

    await animationTicker?.completed;

    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
        SpriteAnimationData.sequenced(
            amount: 10, stepTime: 0.05, textureSize: Vector2(64, 64)));
  }
}
