import 'dart:async';
import 'dart:math';

import 'package:app_asd_diagnostic/games/hit_run/components/background_tile.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/hearts.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/points.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/shape.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/timer.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World with HasGameRef<HitRun> {
  final String levelName;
  final int mode;
  final int amount;

  final List<String> colors;
  final List<String> objects;

  Level(
      {required this.levelName,
      required this.colors,
      required this.mode,
      required this.objects,
      required this.amount});
  late TiledComponent level;
  Points? points;
  Hearts? hearts;
  TimerDisplay? timer;
  List<CollisionBlock> _collisionBlocks = [];
  List<CollisionBlock> get collisionBlocks => _collisionBlocks;
  ShapeForm? selectedShape;
  String spawnedShapeType = '';
  ShapeForm? spawnShape;

  @override
  FutureOr<void> onLoad() async {
    spawnedShapeType = objects[Random().nextInt(objects.length)];

    level = await TiledComponent.load('hit_run/$levelName', Vector2(16, 16));
    level.priority = 10;
    add(level);
    _scrollingBackground();
    _spawingObjects();
    _addCollisions();
    spawnRandomShapeType();

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
        _collisionBlocks.add(block);
      }
    }
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

  void _spawingObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      final rng = Random();
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Spawn':
            int randomValue = rng.nextDouble() < 0.5 ? 0 : 1;
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: false,
                isButton: false,
                color: colors[randomValue]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = spawnedShapeType;
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            spawnShape = shape;
            break;
          case 'Shapes':
            for (int i = 0; i < 4; i++) {
              int randomValue = rng.nextDouble() < 0.5 ? 0 : 1;
              ShapeForm shape = ShapeForm(
                  speed: _randomSpeed(),
                  level: this,
                  isTap: true,
                  isButton: false,
                  color: colors[randomValue]);
              shape.position = Vector2(
                spawnPoint.x + rng.nextDouble() * spawnPoint.width,
                spawnPoint.y + rng.nextDouble() * spawnPoint.height,
              );
              shape.form = objects[0];
              shape.priority = 9999;
              shape.amount = amount;
              add(shape);
            }
            for (int i = 0; i < 4; i++) {
              int randomValue = rng.nextDouble() < 0.5 ? 0 : 1;
              ShapeForm shape = ShapeForm(
                  speed: _randomSpeed(),
                  level: this,
                  isTap: true,
                  isButton: false,
                  color: colors[randomValue]);
              shape.position = Vector2(
                spawnPoint.x + rng.nextDouble() * spawnPoint.width,
                spawnPoint.y + rng.nextDouble() * spawnPoint.height,
              );
              shape.form = objects[1];
              shape.priority = 9999;
              shape.amount = amount;
              add(shape);
            }
            for (int i = 0; i < 4; i++) {
              int randomValue = rng.nextDouble() < 0.5 ? 0 : 1;
              ShapeForm shape = ShapeForm(
                  speed: _randomSpeed(),
                  level: this,
                  isTap: true,
                  isButton: false,
                  color: colors[randomValue]);
              shape.position = Vector2(
                spawnPoint.x + rng.nextDouble() * spawnPoint.width,
                spawnPoint.y + rng.nextDouble() * spawnPoint.height,
              );
              shape.amount = amount;
              shape.form = objects[2];
              shape.priority = 9999;
              add(shape);
            }
            break;
          case 'Square':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true,
                color: colors[0]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = objects[0];
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            break;
          case 'Circle':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true,
                color: colors[0]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = objects[1];
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            break;
          case 'Triangle':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true,
                color: colors[0]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = objects[2];
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            break;
          case 'Square 2':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true,
                color: colors[1]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = objects[0];
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            break;
          case 'Circle 2':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true,
                color: colors[1]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = objects[1];
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            break;
          case 'Triangle 2':
            ShapeForm shape = ShapeForm(
                speed: Vector2.zero(),
                level: this,
                isTap: true,
                isButton: true,
                color: colors[1]);
            shape.position = Vector2(spawnPoint.x, spawnPoint.y);
            shape.form = objects[2];
            shape.priority = 9999;
            shape.amount = 1;
            add(shape);
            break;
          case 'Timer':
            final timer = TimerDisplay(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(timer);
            timer.priority = 9999;
            this.timer = timer;
            break;
          case 'Points':
            final points = Points(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(points);
            points.priority = 9999;
            this.points = points;
            break;
          case 'Hearts':
            final hearts = Hearts(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            hearts.priority = 9999;
            add(hearts);
            this.hearts = hearts;
            break;
        }
      }
    }
  }

  void spawnRandomShapeType() {
    final rng = Random();
    spawnedShapeType = objects[rng.nextInt(objects.length)];
    int randomValue = rng.nextDouble() < 0.5 ? 0 : 1;
    String color = colors[randomValue];

    if (mode == 1) {
      FlameAudio.play('hit_run/${spawnedShapeType}_$color.mp4');
    }

    if (spawnShape != null && mode == 0) {
      remove(spawnShape!);
    }

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      final shapesLayer = spawnPointsLayer.objects
          .firstWhere((layer) => layer.class_ == 'Shapes',
              // ignore: cast_from_null_always_fails
              orElse: () => null as TiledObject);
      final rng = Random();

      ShapeForm shape = ShapeForm(
          speed: _randomSpeed(),
          level: this,
          isTap: true,
          isButton: false,
          color: color);
      shape.position = Vector2(
        shapesLayer.x + rng.nextDouble() * shapesLayer.width,
        shapesLayer.y + rng.nextDouble() * shapesLayer.height,
      );
      shape.form = spawnedShapeType;
      shape.priority = 9999;
      shape.amount = amount;

      add(shape);
    }

    ShapeForm shape = ShapeForm(
        speed: Vector2.zero(),
        level: this,
        isTap: false,
        isButton: false,
        color: colors[randomValue]);
    shape.position = spawnShape?.position.clone() ?? Vector2.zero();
    shape.form = spawnedShapeType;
    shape.priority = 9999;
    shape.amount = amount;

    if (mode == 0) {
      add(shape);
    }
    spawnShape = shape;
  }

  Vector2 _randomSpeed() {
    final random = Random();
    final speed = random.nextDouble() * 50 + 50;
    final angle = random.nextDouble() * 2 * pi;
    return Vector2(cos(angle), sin(angle)) * speed;
  }

  void handleTimerEnd() {
    hearts?.decreaseHearts('timer');
    timer?.resetTimer();
  }
}
