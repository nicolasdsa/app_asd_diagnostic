import 'package:app_asd_diagnostic/screens/games/gift_grab/components/globals.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/menus/menu_background_widget.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/gift_grab.dart';
import 'package:app_asd_diagnostic/screens/games/gift_grab/screens/game_play.dart';
import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  final GiftGrabGame gameRef;
  const SettingsMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuBackgroundWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: Globals.isTablet ? 100 : 50,
                ),
              ),
            ),
            SizedBox(
              width: Globals.isTablet ? 400 : 200,
              height: Globals.isTablet ? 100 : 50,
              child: ElevatedButton(
                onPressed: () {
                  gameRef.removeMenu(menu: Menu.settings);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: Globals.isTablet ? 50 : 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
