import 'package:app_asd_diagnostic/games/gift_grab/components/globals.dart';
import 'package:app_asd_diagnostic/games/gift_grab/gift_grab.dart';
import 'package:app_asd_diagnostic/games/gift_grab/menus/game_over_menu.dart';
import 'package:app_asd_diagnostic/games/gift_grab/menus/main_menu.dart';
import 'package:app_asd_diagnostic/games/gift_grab/menus/settings.menu.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

GiftGrabGame _giftGrabGame = GiftGrabGame();

enum Menu { main, gameOver, settings }

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Globals.isTablet = MediaQuery.of(context).size.width > 600;

    return GameWidget(
      game: _giftGrabGame,
      overlayBuilderMap: {
        Menu.gameOver.name: (BuildContext context, GiftGrabGame gameRef) =>
            GameOverMenu(gameRef: gameRef),
        Menu.main.name: (BuildContext context, GiftGrabGame gameRef) =>
            MainMenu(gameRef: gameRef),
        Menu.settings.name: (BuildContext context, GiftGrabGame gameRef) =>
            SettingsMenu(gameRef: gameRef),
      },
    );
  }
}
