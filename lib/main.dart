import 'package:app_asd_diagnostic/games/hit_run/game.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:app_asd_diagnostic/games/hit_run/screens/menu_screen.dart';
import 'package:app_asd_diagnostic/screens/components/my_bottom_navigation_bar.dart';
import 'package:app_asd_diagnostic/screens/export_screen.dart';
import 'package:app_asd_diagnostic/screens/initial_screen.dart';
import 'package:app_asd_diagnostic/screens/login_screen.dart';
import 'package:app_asd_diagnostic/screens/register_screen.dart';
import 'package:app_asd_diagnostic/screens/test_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/test',
      routes: {
        '/initialLogin': (context) => InitialScreen(),
        '/': (context) => TestScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/test': (context) => const MyBottomNavigationBar(),
        '/export': (context) => const ExportScreen(),
        '/hitRunMenu': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          final idPatient = args['idPatient']!;
          return HitRunMenuScreen(idPatient: idPatient);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/hitRun') {
          final args = settings.arguments as Map<String, String>;
          final idPatient = args['idPatient']!;
          final difficulty = args['difficulty']!;
          final mode = args['mode']!;
          final game =
              HitRun(idPatient: idPatient, difficulty: difficulty, mode: mode);
          return MaterialPageRoute(
            builder: (context) => GameScreen(game: game),
          );
        }
        return null; // Unknown route
      },
    ),
  );
}
