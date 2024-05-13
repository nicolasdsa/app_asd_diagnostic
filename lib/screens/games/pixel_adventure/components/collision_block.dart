import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  // super is used to call the constructor of the parent class and pass the position and size parameters
  CollisionBlock({position, size, this.isPlatform = false})
      : super(position: position, size: size);
}
