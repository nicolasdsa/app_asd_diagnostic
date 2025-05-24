import 'dart:async';
import 'package:app_asd_diagnostic/games/my_routine/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/conditional_barrier.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/interactive.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/player.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/stage.dart';
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<MyGame> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List colisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      levelName,
      Vector2(32, 32),
      atlasMaxX: 16384,
      atlasMaxY: 16384,
    );
    level.priority = 10;
    add(level);

    _spawingObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        if (collision.class_ == 'ConditionalBarrier') {
          final barrier = ConditionalBarrier(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
            requiredObjective: collision.name,
          );
          colisionBlocks.add(barrier);
          add(barrier);
          continue;
        }

        if (collision.class_ == 'Stage') {
          final stage = Stage(
              phrase: collision.name,
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height));
          colisionBlocks.add(stage);
          print('Stage: ${collision.name} - ${collision.x}, ${collision.y}');
          add(stage);
          continue;
        }

        if (collision.class_ == 'Interactive') {
          final interactive = Interactive(
              phrase: collision.name,
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height));
          print(
              'Interactive: ${collision.name} - ${collision.x}, ${collision.y}');
          colisionBlocks.add(interactive);
          add(interactive);
          continue;
        }

        final block = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
        );
        colisionBlocks.add(block);
        add(block);
      }
    }
    player.collisionBlocks = colisionBlocks;
  }

  void _spawingObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Stage':
            final stage = Stage(
                phrase: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(stage);
            break;
        }
      }
    }
  }
}
