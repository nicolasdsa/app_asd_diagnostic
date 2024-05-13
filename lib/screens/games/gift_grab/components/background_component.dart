import 'dart:async';

import 'package:app_asd_diagnostic/screens/games/gift_grab/components/globals.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/gift_grab.dart';
import 'package:flame/components.dart';

class BackgroundComponent extends SpriteComponent
    with HasGameRef<GiftGrabGame> {
  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    await super.onLoad();

    sprite = await gameRef.loadSprite(Globals.backgroundSprite);
    size = gameRef.size;
  }
}
