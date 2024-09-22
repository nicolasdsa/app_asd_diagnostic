import 'dart:async';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/game_stats.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class HitRun extends FlameGame
    with TapCallbacks, HasCollisionDetection, DragCallbacks {
  final String idPatient;
  final Map<String, dynamic> properties;

  HitRun({
    required this.idPatient,
    required this.properties,
  });

  GameStats stats = GameStats();
  List<String> levelNames = ['easy.tmx', 'hard.tmx', 'easy-no-sound.tmx'];
  late CameraComponent cam;
  late Level _level;

  // Variáveis para monitorar o tempo de pressão do toque
  late DateTime _touchStartTime;
  double _holdDuration = 0.0; // Armazena o tempo de hold em segundos

  Level get level => _level;

  @override
  FutureOr<void> onLoad() async {
    stats.startGame();
    await images.loadAllImages();
    _loadLevel();
    return super.onLoad();
  }

  void resetGame() {
    saveGameStats();
    stats.endGame(_level.points);
    stats.startGame();
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData = stats.toJson(_level.points);
    Map<String, dynamic> jsonDataFlag = stats.toJsonFlag();
    Map<String, dynamic> jsonDataDescription = stats.toJsonFlagDescription();

    print('JSON data before saving: $jsonData');
    print('JSON data before saving: $jsonDataFlag');

    JsonDataDao jsonDataDao = JsonDataDao();
    await jsonDataDao.insertJson(
        jsonData,
        idPatient,
        'Hit run - Dificuldade: ${properties['Dificuldade']} - Modo: ${properties['Modos']}',
        jsonDataFlag,
        jsonDataDescription);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // Começa a contar o tempo quando o toque é detectado
    _touchStartTime = DateTime.now();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // Calcula o tempo total de toque
    DateTime touchEndTime = DateTime.now();
    _holdDuration =
        touchEndTime.difference(_touchStartTime).inMilliseconds / 1000.0;
    stats.recordHoldTime(_holdDuration);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Começa a contar o tempo quando o toque é detectado
    _touchStartTime = DateTime.now();
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Calcula o tempo total de toque
    DateTime touchEndTime = DateTime.now();
    _holdDuration =
        touchEndTime.difference(_touchStartTime).inMilliseconds / 1000.0;
    stats.recordHoldTime(_holdDuration);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // Cancela a contagem se o toque for cancelado
    DateTime _touchEndTime = DateTime.now();
    _holdDuration =
        _touchEndTime.difference(_touchStartTime).inMilliseconds / 1000.0;
    stats.recordHoldTime(_holdDuration);
  }

  void _loadLevel() async {
    if (properties["Modos"] == 'Sonoro') {
      levelNames = ['easy.tmx', 'hard.tmx'];
    }

    if (properties["Modos"] == 'Visual') {
      levelNames = ['easy-no-sound.tmx', 'hard-no-sound.tmx'];
    }

    int currentLevelIndex = properties["Dificuldade"] == 'Fácil' ? 0 : 1;
    List<String> colors = ['blue', 'green', 'pink', 'yellow'];
    int flagMode = properties["Modos"] == 'Visual' ? 0 : 1;

    if (currentLevelIndex == 0) {
      colors.shuffle();
      colors = [colors[0], colors[0]];
    }

    if (currentLevelIndex == 1) {
      colors.shuffle();
      colors = colors.take(2).toList();
    }

    _level = Level(
      levelName: levelNames[currentLevelIndex],
      colors: colors,
      mode: flagMode,
    );

    cam = CameraComponent.withFixedResolution(
      world: _level,
      width: 640,
      height: 400,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([cam, _level]);
  }
}
