import 'dart:async';
import 'package:app_asd_diagnostic/games/my_routine/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/interactive.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/player.dart';
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<MyGame> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> colisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2(32, 32));
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
          case 'Interactive':
            final interactive = Interactive(
                phrase: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(interactive);
            break;
        }
      }
    }
  }
}
