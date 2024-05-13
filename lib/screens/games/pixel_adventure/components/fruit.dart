import 'dart:async';

import 'package:app_asd_diagnostic/screens/games/pixel_adventure/components/custom_hitbox.dart';
import 'package:app_asd_diagnostic/screens/games/pixel_adventure/pixel_adventure.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;

  Fruit({this.fruit = 'Apple', position, size})
      : super(position: position, size: size, removeOnFinish: true);

  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);

  final double stepTime = 0.05;

  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/$fruit.png'),
        SpriteAnimationData.sequenced(
          amount: 17,
          stepTime: stepTime,
          textureSize: Vector2(32, 32),
        ));
    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;

      if (game.playSounds) {
        FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: stepTime,
              textureSize: Vector2(32, 32),
              loop: false));
    }

    await animationTicker?.completed;
    removeFromParent();
  }
}
