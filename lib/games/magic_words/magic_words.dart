import 'dart:ui';

import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/background.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/cloud.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/game_stats.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letter_box.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/letters_container.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/tip.dart';
import 'package:app_asd_diagnostic/games/magic_words/components/word_box.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:app_asd_diagnostic/db/words_dao.dart';
import 'dart:math';
import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class JogoFormaPalavrasGame extends FlameGame
    with
        HasCollisionDetection,
        TapCallbacks,
        DragCallbacks,
        WidgetsBindingObserver {
  final WordsDao _wordsDao = WordsDao();
  final Set<int> _usedWordIds = {};
  final List<Map<String, dynamic>> _currentWords = [];
  final List<WordBox> _wordBoxes = [];
  LettersContainer? _lettersContainer;
  final GameStats _stats = GameStats();
  late DateTime _phaseStartTime;
  bool _phaseHadError = false;
  bool _phaseHadTip = false;
  bool _levelCompleted = false;
  late final List<Map<String, dynamic>> _allWords;
  Timer? _tipTimer; // Timer para exibir dicas
  Tip? _currentTip;
  bool _isTransitioning = false; // nova flag
  AudioPlayer? _audioPlayer;

  JogoFormaPalavrasGame({
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;
  List<String> musicTracks = [
    'music_1.mp3',
    'music_2.mp3',
    'music_3.mp3',
    'music_4.mp3',
    'music_5.mp3',
    'music_6.mp3',
    'music_7.mp3',
    'music_8.mp3',
    'music_9.mp3',
    'music_10.mp3',
  ];
  int currentTrackIndex = 0;

  void onWordSolved() {
    _resetTipTimer(); // some a dica atual + reinicia cronômetro
    checkPalavrasCompletas(); // verá se todas as palavras do nível já foram feitas
  }

  // Jogador acertou a palavra
  void onWordCorrect() {
    _resetTipTimer(); // some a dica e inicia novo timer
    checkPalavrasCompletas(); // confere fim de fase
  }

  // Jogador errou a palavra
  void onWordWrong(int wrongLetters) {
    _resetTipTimer();

    // --------- Estatísticas ---------
    _stats.addWrongLetters(wrongLetters);
    if (!_phaseHadError) {
      _stats.addErrorPhase(1);
      _phaseHadError = true;
    }
  }

  void onWrongLetterTap(int n) {
    _stats.addWrongLetters(n);
    if (!_phaseHadError) {
      _stats.addErrorPhase(1);
      _phaseHadError = true;
    }
  }

  @override
  Future<void> onLoad() async {
    // 1) carrega todas as palavras de uma vez
    _allWords = List<Map<String, dynamic>>.from(await _wordsDao.getWords());
    _allWords.sort((a, b) => (a['palavra'] as String)
        .length
        .compareTo((b['palavra'] as String).length));
    WidgetsBinding.instance.addObserver(this);

    _startNewPhase(); // stats, timers, etc.
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(canvasSize.x, canvasSize.y),
    );

    musicTracks.shuffle();
    _audioPlayer = AudioPlayer();
    _audioPlayer?.onPlayerComplete.listen((event) {
      _onMusicComplete();
    });
    _playNextMusic();

    await add(Background());
    await add(Cloud());

    // 2) monta o nível 1
    await _loadAndBuildLevel();
  }

  void _startNewPhase() {
    _stats.startNewPhase();
    _phaseStartTime = DateTime.now();
    _phaseHadError = false;
    _phaseHadTip = false;
    _startTipTimer(); // timer só começa quando inicia fase
  }

  void _startTipTimer() {
    _tipTimer?.cancel(); // Cancela o timer anterior, se existir
    _tipTimer = Timer(const Duration(seconds: 4), _showTip);
  }

  void _resetTipTimer() {
    _startTipTimer(); // Reinicia o timer
    if (_currentTip != null) {
      remove(_currentTip!); // Remove a dica atual, se existir
      _currentTip = null;
    }
  }

  void _showTip() {
    // Verifica quais palavras ainda não foram acertadas
    final availableTips =
        _wordBoxes.where((wordBox) => !wordBox.isInitiallyCorrect).toList();

    if (_currentTip != null) {
      remove(_currentTip!);
      _currentTip = null;
    }

    if (availableTips.isNotEmpty) {
      final randomWordBox =
          availableTips[Random().nextInt(availableTips.length)];
      _currentTip = Tip(
        tip: randomWordBox.tip,
        screenSize: size,
      );
      add(_currentTip!); // Adiciona a dica ao jogo
      randomWordBox
          .waveAnimation(); // Chama a animação de onda para destacar o WordBox

      _stats.addTip(1);
      if (!_phaseHadTip) {
        _stats.addTipPhase(1);
        _phaseHadTip = true;
      }
    }
  }

  Future<void> _carregarPalavras() async {
    final random = Random();

    // Agrupa as palavras por tamanho em ordem crescente
    final Map<int, List<Map<String, dynamic>>> wordsByLength = {};
    for (var word in _allWords) {
      final length = (word['palavra'] as String).length;
      wordsByLength.putIfAbsent(length, () => []).add(word);
    }
    final sortedLengths = wordsByLength.keys.toList()..sort();

    int wordsNeeded = 4;
    for (final length in sortedLengths) {
      final availableWords = wordsByLength[length]!
          .where((w) => !_usedWordIds.contains(w['id']))
          .toList();
      availableWords.shuffle(random);

      for (final word in availableWords) {
        if (_currentWords.length < wordsNeeded) {
          _usedWordIds.add(word['id']);
          _currentWords.add(word);
        } else {
          break;
        }
      }
      if (_currentWords.length >= wordsNeeded) break;
    }

    _currentWords.sort((a, b) => (a['palavra'] as String)
        .length
        .compareTo((b['palavra'] as String).length));
  }

  Future<void> _montarTela() async {
    const double startX = 0;
    const double startY = 50;
    double offsetY = 0;
    for (var word in _currentWords) {
      final wordBox = WordBox(
          letterBoxes: List.generate(
              word['palavra'].length,
              (index) =>
                  LetterBox(position: Vector2.zero(), size: Vector2(50, 50))),
          correctWord: word['palavra'],
          audioButtonPosition: Vector2(startX, startY + offsetY),
          audioPath: word['audio'],
          spritePath: word['imagem'],
          onSolved: onWordSolved,
          onCorrect: onWordCorrect,
          onWrong: onWordWrong,
          onWrongLetterTap: onWrongLetterTap,
          tip: word['dica'],
          immediateCheckMode:
              properties["Dificuldade"] == 'Fácil' ? true : false);

      add(wordBox);
      _wordBoxes.add(wordBox);
      offsetY += 70;
    }

    if (_lettersContainer != null) {
      remove(_lettersContainer!);
      _lettersContainer = null;
    }

    _lettersContainer = LettersContainer(
      letters: _gerarLetrasUnicas(_currentWords),
      startPosition: Vector2(500, 50),
      wordBoxes: _wordBoxes,
      difficulty: properties["Dificuldade"] == 'Fácil' ? true : false,
    );
    add(_lettersContainer!);
  }

  /// Chamado sempre que uma palavra é completa (correta ou não)
  Future<void> _loadAndBuildLevel() async {
    await _carregarPalavras();
    await _montarTela();
    _startTipTimer();
  }

  Future<void> checkPalavrasCompletas() async {
    // bloqueia se já estamos trocando de fase
    if (_levelCompleted || _isTransitioning) return;

    if (!_wordBoxes.every((w) => w.isInitiallyCorrect)) return;

    _levelCompleted = true;
    _isTransitioning = true; // ← trava reentrâncias
    _stats.addPhaseTime(DateTime.now().difference(_phaseStartTime));

    if (_usedWordIds.length < _allWords.length) {
      await _prepareNextLevel();
    } else {
      await saveGameStats();
      pauseEngine();
      _audioPlayer?.stop();
      overlays.add('EndOverlay');
    }

    _isTransitioning = false; // fase nova pronta
    _levelCompleted = false; // libera para a próxima
  }

  /// Remove tudo do nível atual e cria o próximo
  Future<void> _prepareNextLevel() async {
    // 1) limpa fase anterior
    for (final box in _wordBoxes) {
      box.removeFromParent();
    }
    _wordBoxes.clear();
    _currentWords.clear();

    _lettersContainer?.removeFromParent();
    _lettersContainer = null;

    // 2) stats / timers
    _startNewPhase();

    // 3) espera um frame para garantir remoção
    await Future.delayed(const Duration(milliseconds: 50));

    // 4) carrega e constrói a nova fase
    await _loadAndBuildLevel();
  }

  Future<void> saveGameStats() async {
    Map<String, dynamic> jsonData = await _stats.toJson(idPatient, id);
    Map<String, dynamic> jsonDataFlag = _stats.toJsonFlag();
    Map<String, dynamic> jsonDataDescription = _stats.toJsonFlagDescription();

    JsonDataDao jsonDataDao = JsonDataDao();
    await jsonDataDao.insertJson(
        jsonData,
        idPatient,
        'Aventuras no Mundo das Palavras - Dificuldade: ${properties['Dificuldade']}',
        jsonDataFlag,
        jsonDataDescription);
  }

  List<String> _gerarLetrasUnicas(List<Map<String, dynamic>> words) {
    final uniqueLetters = <String>{};
    for (var word in words) {
      uniqueLetters.addAll((word['palavra'] as String).toUpperCase().split(''));
    }

    return uniqueLetters.toList()..shuffle(Random());
  }

  void _onMusicComplete() {
    currentTrackIndex++;
    if (currentTrackIndex >= musicTracks.length) {
      musicTracks.shuffle();
      currentTrackIndex = 0;
    }
    _playNextMusic();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioPlayer?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer?.resume();
    }
  }

  void _playNextMusic() {
    _audioPlayer?.play(
      AssetSource('audio/words_adventure/${musicTracks[currentTrackIndex]}'),
      volume: 0.20,
    );
  }
}
