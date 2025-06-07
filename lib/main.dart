import 'package:app_asd_diagnostic/games/hit_run/game.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:app_asd_diagnostic/games/magic_words/game.dart';
import 'package:app_asd_diagnostic/games/magic_words/magic_words.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/end_overlay.dart';
import 'package:app_asd_diagnostic/games/my_routine/components/stage_menu.dart';
import 'package:app_asd_diagnostic/games/my_routine/game.dart';
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:app_asd_diagnostic/screens/check_credential_screen.dart';
import 'package:app_asd_diagnostic/screens/components/my_bottom_navigation_bar.dart';
import 'package:app_asd_diagnostic/screens/export_screen.dart';
import 'package:app_asd_diagnostic/screens/form_detail_screen.dart';
import 'package:app_asd_diagnostic/screens/game_screen.dart';
import 'package:app_asd_diagnostic/screens/games_screen.dart';
import 'package:app_asd_diagnostic/screens/hash_create_screen.dart';
import 'package:app_asd_diagnostic/screens/patient_detail_screen.dart';
import 'package:app_asd_diagnostic/screens/patients_screen.dart';
import 'package:app_asd_diagnostic/screens/questions_create_screen.dart';
import 'package:app_asd_diagnostic/screens/questions_screen.dart';
import 'package:app_asd_diagnostic/screens/register_screen.dart';
import 'package:app_asd_diagnostic/screens/login_and_hash_screen.dart';
import 'package:app_asd_diagnostic/screens/sounds_create_screen.dart';
import 'package:app_asd_diagnostic/screens/sounds_screen.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
            // DetailPatient: Age, Gender, Description, Diagnosis
            labelSmall: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
                color: Color(0xFF6B7495)),
            // Question: Name and options
            // CreatePatient: Label Name, age, gender, description, diagnosis, foto
            // Sounds
            // Chart
            labelMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
            // CreateQuestion: Button
            labelLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
                color: Colors.white),
            // DetailPatient: Label Description e Diagnosis
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
            // DetailPatient: Informações médicas e Formulários
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            // AppBar: Title
            headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        initialRoute: '/check',
        routes: {
          '/gameView': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as int;
            final idGame = args;
            return GameView(id: idGame);
          },
          '/games': (context) => const GamesScreen(),
          '/sounds': (context) => const SoundsScreen(),
          '/createSound': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?;
            final idSound = args?['idSound'];
            final notifier = args?['notifier'];

            return SoundCreateEditScreen(soundId: idSound, notifier: notifier);
          },
          '/createQuestion': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?;
            final idQuestion = args?['idQuestion'];
            final notifier = args?['notifier'];

            return QuestionCreateScreen(
                questionId: idQuestion, notifier: notifier);
          },
          '/questions': (context) => const QuestionsScreen(),
          '/word_box': (context) => GameWidget(game: JogoFormaPalavrasGame()),
          '/patients': (context) => const PatientScreen(),
          '/check': (context) => const InitialCheckScreen(),
          '/initial': (context) => const MyBottomNavigationBar(),
          '/': (context) => const LoginAndHashScreen(),
          '/register': (context) => RegisterScreen(),
          '/test': (context) => const MyBottomNavigationBar(),
          '/export': (context) => const ExportScreen(),
          '/game': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            final idPatient = args['idPatient']!;
            final elements = args['elements']!;

            return HashCreateScreen(
              idPatient: idPatient,
              elements: elements,
            );
          },
          '/patient': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            final idPatient = args['patientId']!;
            return PatientDetailScreen(patientId: int.parse(idPatient));
          },
          '/form': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, String>;
            final formId = args['formId']!;
            return FormDetailScreen(formId: int.parse(formId));
          },
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/hitRunMenu') {
            final args = settings.arguments as Map<String, dynamic>;
            final idPatient = args['idPatient']!;
            final properties = args['properties']!;
            final id = args['id']!;

            final game =
                HitRun(idPatient: idPatient, properties: properties, id: id);
            return MaterialPageRoute(
              builder: (context) =>
                  GameScreen(game: game, idPatient: int.parse(idPatient)),
            );
          }

          if (settings.name == '/wordsAdventureMenu') {
            final args = settings.arguments as Map<String, dynamic>;
            final idPatient = args['idPatient']!;
            final properties = args['properties']!;
            final id = args['id']!;

            final game = MenuInicial();
            return MaterialPageRoute(
              builder: (context) => game,
            );
          }

          if (settings.name == '/dailyRoutineMenu') {
            final args = settings.arguments as Map<String, dynamic>;
            final idPatient = args['idPatient']!;
            final properties = args['properties']!;
            final id = args['id']!;

            final game = MenuInicialMinhaRotina(
                idPatient: idPatient, properties: properties, id: id);
            return MaterialPageRoute(
              builder: (context) => game,
            );
          }

          if (settings.name == '/routine') {
            final args = settings.arguments as Map<String, dynamic>;
            final idPatient = args['idPatient']!;
            final properties = args['properties']!;
            final id = args['id']!;
            final game = GameWidget<MyRoutine>(
              game: MyRoutine(
                id: id,
                idPatient: idPatient,
                properties: properties,
              ),
              overlayBuilderMap: {
                'StageOverlay': (_, MyRoutine game) {
                  // garante que o MyRoutine já abasteceu esses campos em Stage.collidedWithPlayer()
                  return StageMenuWidget(
                    phaseText: game.currentPhaseText!,
                    iconNames: game.currentIconNames!,
                    correctIcons: game.currentCorrectIcons!,
                    id: game.currentStageId!,
                    timerDuration: game.properties[
                            'Tempo para dica aparecer (segundos)'] ??
                        10,
                    immediateFeedback: game.currentImmediateFeedback =
                        properties["Dificuldade"] == 'Fácil' ? true : false,
                    onComplete: ({
                      required selected,
                      required wrongCount,
                      required hasError,
                      required elapsed,
                      required tipCount,
                      required hasTip,
                    }) {
                      game.stats.addWrongTap(wrongCount);
                      game.stats.addErrorPhase(hasError ? 1 : 0);
                      game.stats.addPhaseTime(elapsed);
                      game.stats.addTip(tipCount);
                      game.stats.addTip(hasTip ? 1 : 0);
                      game.objectives.complete(game.currentStageId!);
                      game.add(game.joystick);
                      game.add(game.actionButton);
                      game.player.freeze = false;
                      game.overlays.remove('StageOverlay');
                      game.resumeEngine();
                    },
                  );
                },
                'EndOverlay': (BuildContext ctx, MyRoutine game) =>
                    EndOverlay(game: game),
              },
              initialActiveOverlays: const [],
            );

            return MaterialPageRoute(
              builder: (context) => game,
            );
          }
        }),
  );
}
