import 'dart:async';
import 'dart:math';

import 'package:app_asd_diagnostic/games/hit_run/components/background_tile.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/shape.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<HitRun> {
  final String levelName;
  Level({required this.levelName});
  late TiledComponent level;
  List<CollisionBlock> _collisionBlocks = [];

  List<CollisionBlock> get collisionBlocks => _collisionBlocks;
  ShapeForm? selectedShape;
  String spawnedShapeType = 'Square';
  ShapeForm? spawnShape; // Variable to keep track of the spawn shape

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('hit_run/$levelName', Vector2(16, 16));
    level.priority = 10;
    add(level);

    _scrollingBackground();
    _spawingObjects();
    _addCollisions();
    spawnRandomShapeType();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        final block = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
          isPlatform: false,
        );
        _collisionBlocks.add(block);
      }
    }
  }

  void _spawingObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      final rng = Random();
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Spawn':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: false,
                isButton: false);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form =
                spawnedShapeType; // Update form based on spawnedShapeType
            shape.priority = 9999;
            add(shape);
            spawnShape = shape; // Keep track of the spawn shape
            break;
          case 'Shapes':
            for (int i = 0; i < 3; i++) {
              ShapeForm shape = ShapeForm(
                  speed: _randomSpeed(),
                  level: this,
                  isTap: true,
                  isButton: false);
              shape.position = Vector2(
                spawnPoint.x + rng.nextDouble() * spawnPoint.width,
                spawnPoint.y + rng.nextDouble() * spawnPoint.height,
              );
              shape.form = 'Circle';
              shape.priority = 9999;
              add(shape);
            }
            for (int i = 0; i < 3; i++) {
              ShapeForm shape = ShapeForm(
                  speed: _randomSpeed(),
                  level: this,
                  isTap: true,
                  isButton: false);
              shape.position = Vector2(
                spawnPoint.x + rng.nextDouble() * spawnPoint.width,
                spawnPoint.y + rng.nextDouble() * spawnPoint.height,
              );
              shape.form = 'Square';
              shape.priority = 9999;
              add(shape);
            }
            for (int i = 0; i < 3; i++) {
              ShapeForm shape = ShapeForm(
                  speed: _randomSpeed(),
                  level: this,
                  isTap: true,
                  isButton: false);
              shape.position = Vector2(
                spawnPoint.x + rng.nextDouble() * spawnPoint.width,
                spawnPoint.y + rng.nextDouble() * spawnPoint.height,
              );
              shape.form = 'Triangle';
              shape.priority = 9999;
              add(shape);
            }
            break;
          case 'Square':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = 'Square';
            shape.priority = 9999;
            add(shape);
            break;
          case 'Circle':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = 'Circle';
            shape.priority = 9999;
            add(shape);
            break;
          case 'Triangle':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = 'Triangle';
            shape.priority = 9999;
            add(shape);
            break;
        }
      }
    }
  }

  void spawnRandomShapeType() {
    final shapes = ['Square', 'Circle', 'Triangle'];
    final rng = Random();
    spawnedShapeType = shapes[rng.nextInt(shapes.length)];
    print('Next shape to be clicked: $spawnedShapeType'); // For debugging

    if (spawnShape != null) {
      // Remove the old spawn shape
      remove(spawnShape!);
    }

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      final shapesLayer = spawnPointsLayer.objects.firstWhere(
          (layer) => layer.class_ == 'Shapes',
          orElse: () => null as TiledObject);
      final rng = Random();
      ShapeForm shape = ShapeForm(
          speed: _randomSpeed(), level: this, isTap: true, isButton: false);
      shape.position = Vector2(
        shapesLayer.x + rng.nextDouble() * shapesLayer.width,
        shapesLayer.y + rng.nextDouble() * shapesLayer.height,
      );
      shape.form = spawnedShapeType;
      shape.priority = 9999;
      add(shape);
    }

    // Create and add a new spawn shape with the updated form
    ShapeForm shape = ShapeForm(
        speed: Vector2.zero(), level: this, isTap: false, isButton: false);
    shape.position = spawnShape?.position?.clone() ?? Vector2.zero();
    shape.form = spawnedShapeType;
    shape.priority = 9999;
    add(shape);
    spawnShape = shape; // Update spawnShape reference
  }

  Vector2 _randomSpeed() {
    final random = Random();
    final speed =
        random.nextDouble() * 50 + 50; // Velocidade aleatória entre 50 e 100
    final angle =
        random.nextDouble() * 2 * pi; // Ângulo aleatório entre 0 e 2pi
    return Vector2(cos(angle), sin(angle)) * speed;
  }
}
