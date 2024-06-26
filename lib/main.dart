import 'package:app_asd_diagnostic/games/hit_run/game.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:app_asd_diagnostic/screens/initial_screen.dart';
import 'package:app_asd_diagnostic/screens/login_screen.dart';
import 'package:app_asd_diagnostic/screens/register_screen.dart';
import 'package:app_asd_diagnostic/screens/test_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HitRun game = HitRun();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/initialLogin': (context) => InitialScreen(),
        '/': (context) => TestScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/hitRun': (context) => GameScreen(game: game),
      },
    ),
  );
}
