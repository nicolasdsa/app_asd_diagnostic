import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:app_asd_diagnostic/games/hit_run/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';

enum PlayerState { shape, shapeSelected, hit }

class ShapeForm extends SpriteAnimationGroupComponent
    with TapCallbacks, DragCallbacks, HasGameRef<HitRun> {
  String form;
  int amount;
  String color;
  Level level;
  bool isTap;
  bool isButton;
  DateTime lastTapTime;
  DateTime? touchStartTime;

  ShapeForm({
    super.position,
    this.form = 'circle',
    this.amount = 4,
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

  late final SpriteAnimation shapeAnimation;
  late final SpriteAnimation shapeSelectedAnimation;
  late final SpriteAnimation hitAnimation;

  List<CollisionBlock> collisionBlocks = [];
  double fixedDeltaTime = 1 / 120;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    collisionBlocks = level.collisionBlocks;

    add(RectangleHitbox(
      position: Vector2(position.x, position.y),
      size: Vector2(width, height),
    ));

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
    shapeAnimation = _spriteAnimation(form, amount, 0.05);
    shapeSelectedAnimation = _spriteAnimation(form, amount, 0.05, true);
    hitAnimation = _spriteHitAnimation();

    animations = {
      PlayerState.shape: shapeAnimation,
      PlayerState.shapeSelected: shapeSelectedAnimation,
      PlayerState.hit: hitAnimation
    };

    current = PlayerState.shape;
  }

  SpriteAnimation _spriteHitAnimation() {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('hit_run/delete.png'),
      SpriteAnimationData.sequenced(
          amount: 5, stepTime: 0.05, textureSize: Vector2.all(32), loop: false),
    );
  }

  SpriteAnimation _spriteAnimation(String form, int amount,
      [double stepTime = 0.1, bool selected = false]) {
    if (selected) {
      return SpriteAnimation.fromFrameData(
        game.images.fromCache('hit_run/${color}_${form}_selected.png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );
    }
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('hit_run/${color}_$form.png'),
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
      FlameAudio.play('hit_run/right_choose.wav', volume: 0.5);
      return;
    }

    FlameAudio.play('hit_run/wrong_choose.mp3', volume: 0.5);
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
      FlameAudio.play('hit_run/right_choose.wav', volume: 0.5);
      return;
    }

    FlameAudio.play('hit_run/wrong_choose.mp3', volume: 0.5);
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
      FlameAudio.play('hit_run/right_choose.wav', volume: 0.5);
      return;
    }

    FlameAudio.play('hit_run/wrong_choose.mp3', volume: 0.5);
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
    FlameAudio.play('hit_run/choose.wav', volume: 0.5);
    updateSprite(true);

    // Define esta forma como a selecionada
    level.selectedShape = this;
  }

  bool _isCorrectShapeTapped() {
    return level.spawnedShapeType == form &&
        level.selectedShape?.form == form &&
        level.selectedShape?.color == color;
  }

  void _handleCorrectTap(dynamic event) async {
    DateTime now = DateTime.now();
    double reactionTime = now.difference(lastTapTime).inMilliseconds / 1000.0;
    gameRef.stats.recordReactionTime(reactionTime);

    double accuracy = _calculateTapAccuracy(event.localPosition);
    gameRef.stats.recordTapAccuracy(accuracy);

    current = PlayerState.hit;
    await animationTicker?.completed;
    animationTicker?.reset();

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
      current = PlayerState.shapeSelected;
    } else {
      current = PlayerState.shape;
    }
  }
}
