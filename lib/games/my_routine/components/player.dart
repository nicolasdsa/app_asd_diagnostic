import 'package:app_asd_diagnostic/games/my_routine/components/interactive.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/collision_block.dart';
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:flame/collisions.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final JoystickComponent joystick;
  final ButtonComponent actionButton;
  final double speed = 100;
  late final Map<String, SpriteAnimation> animations;
  String currentDirection = 'down';
  List<CollisionBlock> collisionBlocks = [];
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  Interactive? currentInteractive;

  // Receber o joystick como parâmetro
  Player({required this.joystick, required this.actionButton})
      : super(size: Vector2.all(32));
  @override
  Future<void> onLoad() async {
    // Carrega a folha de sprite e configura as animações
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

    // Adiciona um hitbox para detectar colisões
    add(RectangleHitbox());

    actionButton.onPressed = () {
      print('Chamou');

      if (currentInteractive != null) {
        currentInteractive!.toggleInteraction();
      }
    };
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Atualiza a direção com base na entrada do joystick
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

    // Se houver um interactive ativo com texto exibido, não permite movimento
    if (currentInteractive == null || !currentInteractive!.isTextActive) {
      Vector2 delta = joystick.relativeDelta * speed * dt;
      position.add(delta);

      // Verifica colisões com os blocos de colisão
      for (final block in collisionBlocks) {
        if (block.toRect().overlaps(toRect())) {
          // Reverte a posição se houver colisão
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
    if (other is Interactive) {
      currentInteractive = other;
      other.collidedWithPlayer();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Interactive && currentInteractive == other) {
      other.hideText();
      currentInteractive = null;
    }
    super.onCollisionEnd(other);
  }
}
