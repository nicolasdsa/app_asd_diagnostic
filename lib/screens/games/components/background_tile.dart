import 'dart:async';

import 'package:app_asd_diagnostic/screens/games/pixel_adventure.dart';
import 'package:flame/components.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({this.color = 'Gray', position}) : super(position: position);

  final double scrollSpeed = 1;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    size = Vector2(64.6, 64.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    double tileSize = 64;
    int scrollheight = (game.size.y / tileSize).floor();
    if (position.y > scrollheight * tileSize) {
      // Reset the position of the tile
      position.y = -tileSize;
    }
    super.update(dt);
  }
}
