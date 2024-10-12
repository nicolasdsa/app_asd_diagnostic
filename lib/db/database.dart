import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/db/highscore_hit_run_dao.dart';
import 'package:app_asd_diagnostic/db/hit_run_objects_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_response_dao.dart';
import 'package:app_asd_diagnostic/db/objective_dao.dart';
import 'package:app_asd_diagnostic/db/option_response_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/patient_object_hit_run_dao.dart';
import 'package:app_asd_diagnostic/db/patient_points_hit_run_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/sound_dao.dart';
import 'package:app_asd_diagnostic/db/sound_response_dao.dart';
import 'package:app_asd_diagnostic/db/text_response_dao.dart';
import 'package:app_asd_diagnostic/db/type_form_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:app_asd_diagnostic/db/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  Future<Database?> get database1 async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(FormDao.tableSql);
    await db.execute(AnswerOptionsDao.tableSql);
    await db.execute(PatientDao.tableSql);
    await db.execute(TypeQuestionDao.tableSql);
    await db.execute(QuestionDao.tableSql);
    await db.execute(TypeFormDao.tableSql);
    await db.execute(UserDao.tableSql);
    await db.execute(GameDao.tableSql);
    await db.execute(HashAccessDao.tableSql);
    await db.execute(JsonDataDao.tableSql);
    await db.execute(TextResponseDao.tableSql);
    await db.execute(OptionResponseDao.tableSql);
    await db.execute(JsonDataResponseDao.tableSql);
    await db.execute(SoundDao.tableSql);
    await db.execute(SoundResponseDao.tableSql);
    await db.execute(HitRunObjectDao.tableSql);
    await db.execute(PatientObjectHitRunDao.tableSql);
    await db.execute(ObjectiveDao.tableSql);
    await db.execute(HighScoreHitRunDao.tableSql);
    await db.execute(PatientPointsHitRunDao.tableSql);

    await db.insert('type_forms', {'name': 'Analise de informações'});
    await db.insert('type_forms', {'name': 'Avaliar Comportamento'});

    await db.insert('type_questions', {'name': 'Simples'});
    await db.insert('type_questions', {'name': 'Multipla escolha'});

    await db.insert('hit_run_objects', {
      'name': 'Formas',
      'objects': '["circle", "square", "rhombus"]',
      'path': 'assets/images/hit_run/pecas.gif',
      'amount': 1,
      'points': 0
    });
    await db.insert('hit_run_objects', {
      'name': 'Animais da Fazenda',
      'objects': '["chicken", "pig", "cow"]',
      'path': 'assets/images/hit_run/animais.gif',
      'amount': 4,
      'points': 50
    });

    await db.insert('games', {
      'name': 'Hit run',
      'link': '/hitRunMenu',
      'config':
          "{\"Modos\": [\"Sonoro\", \"Visual\"],\"Dificuldade\": [\"Difícil\", \"Fácil\"],\"Vidas\": 3,\"Tempo\": 5}",
      'path': 'assets/images/hit_run/hit_run_logo.jpeg',
      'short_description':
          'Teste a atenção e reflexos em um jogo dinâmico onde é necessário identificar e selecionar os elementos em movimento na tela, de acordo com o item indicado.',
      'long_description':
          'Neste jogo interativo, o objetivo é observar atentamente a tela e identificar os elementos que estão se movendo conforme o objeto ou padrão indicado. À medida que os elementos se movimentam, é necessário selecionar apenas aqueles que correspondem à indicação fornecida. O ritmo aumenta progressivamente, exigindo que uma reação de forma rápida e precisa. Com diferentes níveis de dificuldade e diversos tipos de elementos, este jogo é perfeito para testar habilidades de observação e resposta.'
    });

    await db.insert('objectives', {
      'game_id': 1,
      'objective': 'Tempo de reação',
    });

    await db.insert('objectives', {
      'game_id': 1,
      'objective': 'Atenção',
    });

    await db.insert('objectives', {
      'game_id': 1,
      'objective': 'Memória de trabalho',
    });

    await db.insert('objectives', {
      'game_id': 1,
      'objective': 'Percepção visual',
    });

    await db.insert('objectives', {
      'game_id': 1,
      'objective': 'Coordenação motora',
    });

    await db.insert('objectives', {
      'game_id': 1,
      'objective': 'Percepção sonora',
    });
    /**/
    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 10, 'name': "ZAF"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 20, 'name': "MRO"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 30, 'name': "PLT"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 40, 'name': "GNI"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 50, 'name': "VEX"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 60, 'name': "KUR"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 80, 'name': "DIP"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 100, 'name': "JYW"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 150, 'name': "CEB"});

    await db.insert(
        'highscore_hit_run', {'game_id': 1, 'points': 200, 'name': "FOT"});
  }

  _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }
}
