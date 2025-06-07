import 'package:app_asd_diagnostic/games/my_routine/components/conditional_barrier.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/interactive.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/stage.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:flame/collisions.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<MyRoutine>, CollisionCallbacks {
  final JoystickComponent joystick;
  final ButtonComponent actionButton;
  final double speed = 100;
  late final Map<String, SpriteAnimation> animations;
  String currentDirection = 'down';
  List collisionBlocks = [];
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  Interactive? currentInteractive;
  bool freeze = false;

  /// Ícone que indica interação disponível
  late SpriteComponent interactionIcon;

  Player({required this.joystick, required this.actionButton})
      : super(size: Vector2.all(32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Carrega animações do personagem
    final spriteSheet =
        await gameRef.images.load('my_routine/Premade_Character_32x32_01.png');
    animations = {
      'down': SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 48),
          texturePosition: Vector2(576, 144),
        ),
      ),
      'up': SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 48),
          texturePosition: Vector2(192, 144),
        ),
      ),
      'left': SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 48),
          texturePosition: Vector2(384, 144),
        ),
      ),
      'right': SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(32, 48),
          texturePosition: Vector2(0, 144),
        ),
      ),
      'idle': SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.2,
          textureSize: Vector2(32, 48),
          texturePosition: Vector2(576, 83),
        ),
      ),
    };

    animation = animations['down'];

    add(RectangleHitbox());

    // Prepara o ícone de interação
    final iconImage = await gameRef.images.load('my_routine/interactive.png');
    interactionIcon = SpriteComponent(
      sprite: Sprite(iconImage),
      size: Vector2(24, 24),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, -4),
    );

    actionButton.onPressed = () {
      if (currentInteractive != null) {
        currentInteractive!.toggleInteraction();
        if (interactionIcon.isMounted) interactionIcon.removeFromParent();
      }
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (freeze) return;

    // Somente para Interactive puro
    if (currentInteractive != null &&
        currentInteractive.runtimeType == Interactive) {
      if (currentInteractive!.isTextActive) {
        if (interactionIcon.isMounted) interactionIcon.removeFromParent();
      } else {
        if (!interactionIcon.isMounted) add(interactionIcon);
      }
    }

    // Lógica de movimento e colisões continua igual...
    switch (joystick.direction) {
      case JoystickDirection.down:
        currentDirection = 'down';
        break;
      case JoystickDirection.up:
        currentDirection = 'up';
        break;
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        currentDirection = 'left';
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        currentDirection = 'right';
        break;
      case JoystickDirection.idle:
        currentDirection = 'idle';
        break;
    }

    if (currentInteractive == null || !currentInteractive!.isTextActive) {
      Vector2 delta = joystick.relativeDelta * speed * dt;
      position.add(delta);
      for (final block in collisionBlocks) {
        if ((block is ConditionalBarrier || block is Stage) &&
            block.toRect().overlaps(toRect())) {
          block.collidedWithPlayer();
          position.sub(delta);
          break;
        }
        if (block.toRect().overlaps(toRect())) {
          position.sub(delta);
          break;
        }
      }
    }

    animation = animations[currentDirection];
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // Só considera Interactive direto (não subclasses)
    if (other is Interactive) {
      other.collidedWithPlayer();
    }

    if (other is Interactive && other.runtimeType == Interactive) {
      currentInteractive = other;
      if (!interactionIcon.isMounted) add(interactionIcon);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    // Se era um Interactive “puro”, garante que o ícone suma
    if (other is Interactive && other.runtimeType == Interactive) {
      if (interactionIcon.isMounted) {
        interactionIcon.removeFromParent();
      }
    }

    // Aí sim zera o currentInteractive
    if (other is Interactive && other == currentInteractive) {
      other.hideText();
      currentInteractive = null;
    }
  }
}
