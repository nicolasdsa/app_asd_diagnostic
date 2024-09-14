import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:app_asd_diagnostic/games/pixel_adventure/components/collision_block.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

enum PlayerState {
  square,
  circle,
  triangle,
  squareSelected,
  circleSelected,
  triangleSelected
}

class ShapeForm extends SpriteAnimationGroupComponent
    with TapCallbacks, DragCallbacks, HasGameRef<HitRun> {
  String form;
  String color;
  Level level;
  bool isTap;
  bool isButton;
  DateTime lastTapTime;
  DateTime? touchStartTime;

  ShapeForm({
    super.position,
    this.form = 'circle',
    required this.color,
    required this.speed,
    required this.level,
    required this.isTap,
    required this.isButton,
  }) : lastTapTime = DateTime.now() {
    _adjustRandomAngle();
  }

  Vector2 startingPosition = Vector2.zero();
  Vector2 speed;
  bool isSelected = false;

  late final SpriteAnimation circleAnimation;
  late final SpriteAnimation squareAnimation;
  late final SpriteAnimation triangleAnimation;
  late final SpriteAnimation triangleSelectedAnimation;
  late final SpriteAnimation squareSelectedAnimation;
  late final SpriteAnimation circleSelectedAnimation;
  List<CollisionBlock> collisionBlocks = [];
  double fixedDeltaTime = 1 / 120;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    collisionBlocks = level.collisionBlocks;
    if (form == 'circle') {
      add(CircleHitbox(radius: width / 2));
    } else if (form == 'square') {
      add(RectangleHitbox(
        position: Vector2(position.x, position.y),
        size: Vector2(width, height),
      ));
    } else if (form == 'triangle') {
      add(PolygonHitbox([
        Vector2(0, 0),
        Vector2(width, 0),
        Vector2(width / 2, height),
      ]));
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      _verifyCollision(fixedDeltaTime);
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    circleAnimation = _spriteAnimation('circle', 1, 0.01);
    squareAnimation = _spriteAnimation('square', 1, 0.01);
    triangleAnimation = _spriteAnimation('rhombus', 1, 0.01);
    squareSelectedAnimation = _spriteAnimation('square', 1, 0.01, true);
    circleSelectedAnimation = _spriteAnimation('circle', 1, 0.01, true);
    triangleSelectedAnimation = _spriteAnimation('rhombus', 1, 0.01, true);

    animations = {
      PlayerState.square: squareAnimation,
      PlayerState.circle: circleAnimation,
      PlayerState.triangle: triangleAnimation,
      PlayerState.squareSelected: squareSelectedAnimation,
      PlayerState.circleSelected: circleSelectedAnimation,
      PlayerState.triangleSelected: triangleSelectedAnimation,
    };

    if (form == 'Circle') {
      current = PlayerState.circle;
    } else if (form == 'Square') {
      current = PlayerState.square;
    } else if (form == 'Triangle') {
      current = PlayerState.triangle;
    }
  }

  SpriteAnimation _spriteAnimation(String form, int amount,
      [double stepTime = 0.1, bool selected = false]) {
    if (selected) {
      return SpriteAnimation.fromFrameData(
        game.images.fromCache('hit_run/${color}_body_${form}_selected.png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );
    }
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('hit_run/${color}_body_$form.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _verifyCollision(double dt) {
    Vector2 oldPosition = position.clone();

    Vector2 step = speed * dt;
    int steps = step.length.ceil();
    Vector2 smallStep = step / steps.toDouble();

    for (int i = 0; i < steps; i++) {
      position += smallStep;

      bool collisionDetected = false;
      for (var block in collisionBlocks) {
        Rect collisionRect = block.toRect();
        if (collisionRect.overlaps(toRect())) {
          collisionDetected = true;
          break;
        }
      }

      if (collisionDetected) {
        position = oldPosition;
        _bounceWithAngleAdjustment();
        break;
      }

      oldPosition = position.clone();
    }
  }

  void _bounceWithAngleAdjustment() {
    speed = -speed;
    _adjustAngle();
  }

  void _adjustAngle() {
    double angleAdjustment = (Random().nextDouble() - 0.5) * 0.1;
    double currentSpeed = speed.length;
    double currentAngle = atan2(speed.y, speed.x);
    double newAngle = currentAngle + angleAdjustment;
    speed = Vector2(cos(newAngle), sin(newAngle)) * currentSpeed;
  }

  void _adjustRandomAngle() {
    double initialAngle = Random().nextDouble() * 2 * pi;
    double currentSpeed = speed.length;
    speed = Vector2(cos(initialAngle), sin(initialAngle)) * currentSpeed;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // Começa a contar o tempo quando o toque é detectado
    touchStartTime = DateTime.now();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    DateTime touchEndTime = DateTime.now();

    // Calcula o tempo total de toque
    double holdDuration =
        touchEndTime.difference(touchStartTime!).inMilliseconds / 1000.0;
    gameRef.stats.recordHoldTime(holdDuration);

    if (!isTap || isButton) {
      return;
    }

    // Verifica se a forma correta foi tocada
    if (_isCorrectShapeTapped()) {
      _handleCorrectTap(event);
      return;
    }

    _handleIncorrectTap();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    DateTime touchEndTime = DateTime.now();

    // Calcula o tempo total de toque
    double holdDuration =
        touchEndTime.difference(touchStartTime!).inMilliseconds / 1000.0;
    gameRef.stats.recordHoldTime(holdDuration);

    if (!isTap || isButton) {
      return;
    }

    if (_isCorrectShapeTapped()) {
      _handleCorrectTap(event);
      return;
    }

    _handleIncorrectTap();
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Finaliza o timer quando o toque é solto
    DateTime touchEndTime = DateTime.now();

    double holdDuration =
        touchEndTime.difference(touchStartTime!).inMilliseconds / 1000.0;
    gameRef.stats.recordHoldTime(holdDuration);

    if (!isTap || isButton) {
      return;
    }

    // Verifica se a forma correta foi tocada
    if (_isCorrectShapeTapped()) {
      _handleCorrectTap(event);
      return;
    }

    _handleIncorrectTap();
  }

  @override
  void onTapDown(TapDownEvent event) {
    touchStartTime = DateTime.now();

    // Se não é possível realizar o tap, retorna
    if (!isTap) {
      return;
    }

    // Verifica se o jogador está tocando em um botão/form selecionado
    if (isButton) {
      _selectShape();
      return;
    }
  }

  void _selectShape() {
    if (level.selectedShape != null) {
      // Reverte o sprite da forma anteriormente selecionada
      level.selectedShape!.updateSprite(false);
    }

    // Atualiza o sprite para o estado selecionado
    updateSprite(true);

    // Define esta forma como a selecionada
    level.selectedShape = this;
    print('Shape Selected: $form');
  }

  bool _isCorrectShapeTapped() {
    return level.spawnedShapeType == form &&
        level.selectedShape?.form == form &&
        level.selectedShape?.color == color;
  }

  void _handleCorrectTap(dynamic event) {
    DateTime now = DateTime.now();
    double reactionTime = now.difference(lastTapTime).inMilliseconds / 1000.0;
    gameRef.stats.recordReactionTime(reactionTime);

    double accuracy = _calculateTapAccuracy(event.localPosition);
    gameRef.stats.recordTapAccuracy(accuracy);

    // Gera uma nova forma aleatória para o jogador
    level.spawnRandomShapeType();
    removeFromParent();

    // Reseta o timer e adiciona pontos
    level.timer?.resetTimer();
    level.points?.addPoints(1);
    lastTapTime = now;
  }

  void _handleIncorrectTap() {
    // Remove um coração se o jogador tocar na forma incorreta
    level.hearts?.decreaseHearts('shape');
  }

  double _calculateTapAccuracy(Vector2 tapPosition) {
    Vector2 convertTapPosition =
        Vector2(tapPosition.x + position.x, tapPosition.y + position.y);
    // Centro da forma

    Vector2 center = Vector2(position.x + width / 2, position.y + height / 2);

    // Distância máxima possível (do centro ao canto mais distante da forma)
    double maxDistance = sqrt(pow(width / 2, 2) + pow(height / 2, 2));

    // Distância entre o toque e o centro
    double tapDistance = convertTapPosition.distanceTo(center);

    // Calcular a porcentagem de precisão (quanto mais perto do centro, maior)
    double accuracy = 100 * (1 - (tapDistance / maxDistance));

    // Limita a precisão entre 0% e 100%
    accuracy = accuracy.clamp(0, 100);

    return accuracy;
  }

  void updateSprite(bool isSelected) {
    if (isSelected) {
      if (form == 'Circle') {
        current = PlayerState.circleSelected;
      } else if (form == 'Square') {
        current = PlayerState.squareSelected;
      } else if (form == 'Triangle') {
        current = PlayerState.triangleSelected;
      }
    } else {
      if (form == 'Circle') {
        current = PlayerState.circle;
      } else if (form == 'Square') {
        current = PlayerState.square;
      } else if (form == 'Triangle') {
        current = PlayerState.triangle;
      }
    }
  }
}
