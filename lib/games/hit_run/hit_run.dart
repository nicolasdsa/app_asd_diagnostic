import 'dart:async';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/db/patient_object_hit_run_dao.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/game_stats.dart';
import 'package:app_asd_diagnostic/games/hit_run/components/level_design.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';

class HitRun extends FlameGame
    with
        TapCallbacks,
        HasCollisionDetection,
        DragCallbacks,
        WidgetsBindingObserver {
  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;
  bool isPaused = false;

  HitRun({
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  GameStats stats = GameStats();
  List<String> levelNames = [
    'easy.tmx',
    'hard.tmx',
    'easy-no-sound.tmx',
    'hard-no-sound.tmx'
  ];

  late CameraComponent cam;
  late Level _level;

  // Variáveis para monitorar o tempo de pressão do toque
  late DateTime _touchStartTime;
  double _holdDuration = 0.0; // Armazena o tempo de hold em segundos
  AudioPlayer? _audioPlayer;

  Level get level => _level;
  // Lista de músicas
  List<String> musicTracks = [
    'music_1.mp3',
    'music_2.mp3',
    'music_3.mp3',
    'music_4.mp3',
    'music_5.mp3',
    'music_6.mp3',
    'music_7.mp3',
    'music_8.mp3'
  ];
  int currentTrackIndex = 0;

  void startGame() {
    stats.startGame(); // Inicia as estatísticas
    _loadLevel(); // Carrega o nível
    overlays.remove('MenuOverlay'); // Remove o menu
  }

  void pauseGame() {
    isPaused = true;
    pauseEngine();
    overlays.add('PauseOverlay'); // Mostra o overlay de pausa
  }

  void resumeGame() {
    isPaused = false;
    resumeEngine();
    overlays.remove('PauseOverlay'); // Remove o overlay de pausa
  }

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    overlays.add('MenuOverlay'); // Mostra o menu ao iniciar o jogo
    musicTracks.shuffle();
    overlays.add('MenuOverlay'); // Mostra o menu ao iniciar o jogo
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerComplete.listen((event) {
      _onMusicComplete(); // Função chamada ao terminar a música
    });
    _playNextMusic();
    WidgetsBinding.instance.addObserver(this);
    return super.onLoad();
  }

  void resetGame() async {
    await saveGameStats();
    stats.endGame(_level.points);
    stats.startGame();
  }

  // Função para tocar a próxima música
  void _playNextMusic() {
    _audioPlayer?.play(
        AssetSource('audio/hit_run/${musicTracks[currentTrackIndex]}'),
        volume: 0.20);
  }

  // Função chamada quando uma música termina
  void _onMusicComplete() {
    // Avança para a próxima música, embaralha se necessário
    currentTrackIndex++;
    if (currentTrackIndex >= musicTracks.length) {
      musicTracks.shuffle(); // Embaralha a lista de músicas
      currentTrackIndex = 0; // Reseta o índice
    }
    _playNextMusic(); // Toca a próxima música
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData =
        await stats.toJson(_level.points, idPatient, id);
    Map<String, dynamic> jsonDataFlag = stats.toJsonFlag();
    Map<String, dynamic> jsonDataDescription = stats.toJsonFlagDescription();

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
    if (isPaused) return;

    super.onDragStart(event);

    // Começa a contar o tempo quando o toque é detectado
    _touchStartTime = DateTime.now();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isPaused) return;

    super.onDragEnd(event);
    // Calcula o tempo total de toque
    DateTime touchEndTime = DateTime.now();
    _holdDuration =
        touchEndTime.difference(_touchStartTime).inMilliseconds / 1000.0;
    stats.recordHoldTime(_holdDuration);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isPaused) return;
    _touchStartTime = DateTime.now();
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (isPaused) return;
    DateTime touchEndTime = DateTime.now();
    _holdDuration =
        touchEndTime.difference(_touchStartTime).inMilliseconds / 1000.0;
    stats.recordHoldTime(_holdDuration);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (isPaused) return;

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

    final patientObject = PatientObjectHitRunDao();
    final objects = await patientObject.getObject(int.parse(idPatient));
    List<String> objectList = objects["objects"]
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(', ');

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
        objects: objectList,
        mode: flagMode,
        amount: objects["amount"]);

    cam = CameraComponent.withFixedResolution(
      world: _level,
      width: 640,
      height: 400,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([cam, _level]);
  }

  // Método que lida com as mudanças de estado do ciclo de vida do app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _audioPlayer?.pause(); // Pausa a música ao minimizar o app
    } else if (state == AppLifecycleState.resumed) {
      if (!isPaused) {
        _audioPlayer
            ?.resume(); // Retoma a música quando o app volta, se o jogo não estiver pausado
      }
    }
  }
}
