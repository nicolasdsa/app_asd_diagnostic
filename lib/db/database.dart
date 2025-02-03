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
import 'package:app_asd_diagnostic/db/words_dao.dart';
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
    await db.execute(WordsDao.tableSql);

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

    await db.insert('games', {
      'name': 'Aventuras no Mundo das Palavras',
      'link': '/wordsAdventureMenu',
      'config': "{\"Dificuldade\": [\"Difícil\", \"Fácil\"]}",
      'path': 'assets/images/hit_run/hit_run_logo.jpeg',
      "short_description":
          "Construa palavras combinando letras corretamente, enquanto estimula a atenção, a linguagem e a percepção visual em um desafio divertido.",
      "long_description":
          "Em *Forma Palavras*, as crianças são desafiadas a formar palavras a partir de letras apresentadas na tela. O jogo envolve a seleção e combinação correta dos elementos disponíveis para completar a palavra-alvo, que pode ser acompanhada por imagens ou dicas sonoras para maior interatividade. Conforme o jogador avança, a dificuldade aumenta com palavras mais complexas e menos tempo disponível, incentivando a atenção sustentada, o desenvolvimento linguístico e a tomada de decisões rápidas. Projetado para proporcionar aprendizado e diversão, este jogo é uma excelente ferramenta para o estímulo cognitivo e verbal de forma lúdica."
    });

    await db.insert('words', {
      'palavra': 'Sapo',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/frog.jpeg',
      'audio': 'assets/audio/words_adventure/frog.wav',
      'dica': 'Animal verde que pula!'
    });

    await db.insert('words', {
      'palavra': 'Trem',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/frog.jpeg',
      'audio': 'assets/audio/words_adventure/frog.wav',
      'dica': 'Máquina grande nos trilhos!'
    });

    await db.insert('words', {
      'palavra': 'Vaca',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/cow.jpeg',
      'audio': 'assets/audio/words_adventure/cow.wav',
      'dica': 'Animal que faz "muu"!'
    });

    await db.insert('words', {
      'palavra': 'Bola',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/ball.jpeg',
      'audio': 'assets/audio/words_adventure/ball.wav',
      'dica': 'Objeto redondo para brincar!'
    });

    await db.insert('words', {
      'palavra': 'Sino',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/bell.jpeg',
      'audio': 'assets/audio/words_adventure/bell.wav',
      'dica': 'Emite um som "ding-dong"!'
    });

    await db.insert('words', {
      'palavra': 'Porta',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/door.jpeg',
      'audio': 'assets/audio/words_adventure/door.wav',
      'dica': 'Abre e fecha com um rangido!'
    });

    await db.insert('words', {
      'palavra': 'Pato',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/duck.jpeg',
      'audio': 'assets/audio/words_adventure/duck.wav',
      'dica': 'Brinquedo que faz "quack"!'
    });

    await db.insert('words', {
      'palavra': 'Fogo',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/fire.jpeg',
      'audio': 'assets/audio/words_adventure/fire.wav',
      'dica': 'Quente e cheio de faíscas!'
    });

    await db.insert('words', {
      'palavra': 'Rato',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/rat.jpeg',
      'audio': 'assets/audio/words_adventure/rat.wav',
      'dica': 'Pequeno e adora queijo!'
    });

    await db.insert('words', {
      'palavra': 'Galo',
      'modo': 'fácil',
      'imagem': 'words_adventure/icons/rooster.jpeg',
      'audio': 'assets/audio/words_adventure/rooster.wav',
      'dica': 'Canta ao amanhecer!'
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
