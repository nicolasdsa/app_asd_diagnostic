/*import 'package:app_asd_diagnostic/screens/initial_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<int> formChangeNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ValueListenableBuilder(
              valueListenable: formChangeNotifier,
              builder: (context, value, child) {
                return InitialScreen(formChangeNotifier: formChangeNotifier);
              },
            )
      },
    );
  }
}*/

/* Teste Pixel Adventure */
/*import 'package:app_asd_diagnostic/games/gift_grab/gift_grab.dart';
import 'package:app_asd_diagnostic/games/pixel_adventure/pixel_adventure.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();
  await Flame.device.fullScreen();
  runApp(
    GameWidget(game: kDebugMode ? PixelAdventure() : game),
  );
}*/

/* Teste Gift_Grab */
/*import 'package:app_asd_diagnostic/games/gift_grab/screens/game_play.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePlay(),
    ),
  );
}*/

import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  HitRun game = HitRun();
  await Flame.device.fullScreen();
  runApp(
    GameWidget(game: kDebugMode ? HitRun() : game),
  );
}
