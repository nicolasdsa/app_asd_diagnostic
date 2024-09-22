import 'package:app_asd_diagnostic/games/hit_run/game.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:app_asd_diagnostic/games/hit_run/screens/menu_screen.dart';
import 'package:app_asd_diagnostic/screens/components/my_bottom_navigation_bar.dart';
import 'package:app_asd_diagnostic/screens/export_screen.dart';
import 'package:app_asd_diagnostic/screens/form_detail_screen.dart';
import 'package:app_asd_diagnostic/screens/hash_create_screen.dart';
import 'package:app_asd_diagnostic/screens/login_screen.dart';
import 'package:app_asd_diagnostic/screens/patient_detail_screen.dart';
import 'package:app_asd_diagnostic/screens/register_screen.dart';
import 'package:app_asd_diagnostic/screens/test_screen.dart';
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
      initialRoute: '/test',
      routes: {
        '/initialLogin': (context) => const MyBottomNavigationBar(),
        '/': (context) => TestScreen(),
        '/login': (context) => LoginScreen(),
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
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          final idPatient = args['patientId']!;
          return PatientDetailScreen(patientId: int.parse(idPatient));
        },
        '/form': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          final formId = args['formId']!;
          return FormDetailScreen(formId: int.parse(formId));
        },
        /*'/hitRunMenu': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          final idPatient = args['idPatient']!;
          return HitRunMenuScreen(idPatient: idPatient);
        },*/
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/hitRunMenu') {
          final args = settings.arguments as Map<String, dynamic>;
          final idPatient = args['idPatient']!;
          final properties = args['properties']!;
          final game = HitRun(idPatient: idPatient, properties: properties);
          return MaterialPageRoute(
            builder: (context) => GameScreen(game: game),
          );
        }
        return null; // Unknown route
      },
    ),
  );
}
