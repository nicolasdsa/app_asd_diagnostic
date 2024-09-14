import 'package:app_asd_diagnostic/games/hit_run/components/points.dart';

class GameStats {
  List<double> reactionTimes = [];
  DateTime sessionStartTime;
  DateTime? gameStartTime;
  int totalGames = 0;
  double totalHoldTime = 0;
  int successfulTaps = 0;
  double totalAccuracy = 0;
  List<String> causeOfLose = [];

  GameStats() : sessionStartTime = DateTime.now();

  void startGame() {
    gameStartTime = DateTime.now();
    totalGames += 1;
  }

  void recordTapAccuracy(double accuracy) {
    totalAccuracy += accuracy;
    successfulTaps++;
  }

  // Método para obter a média de precisão dos toques
  double getAverageAccuracy() {
    if (successfulTaps == 0) return 0;
    return totalAccuracy / successfulTaps;
  }

  // Adiciona um novo método para registrar o tempo de pressão
  void recordHoldTime(double holdTime) {
    totalHoldTime += holdTime;
  }

  // Método para obter o tempo médio de pressão
  double getAverageHoldTime() {
    if (successfulTaps == 0) return 0;
    return totalHoldTime / successfulTaps;
  }

  void endGame(Points? pointsComponent) {
    if (gameStartTime != null) {
      gameStartTime = null;
      pointsComponent!.resetPoints(); // Reseta os pontos
      reactionTimes = [];
      totalHoldTime = 0;
      successfulTaps = 0;
      totalAccuracy = 0;
      gameStartTime = DateTime.now();
      totalGames += 1;
      causeOfLose = [];
    }
  }

  void recordReactionTime(double reactionTime) {
    reactionTimes.add(reactionTime);
  }

  String _determineCauseOfLose() {
    int shapeCount = causeOfLose.where((cause) => cause == 'shape').length;
    int timerCount = causeOfLose.where((cause) => cause == 'timer').length;

    return timerCount > shapeCount ? '0' : '1';
  }

  String _determineAction() {
    if (successfulTaps == 0 &&
        totalHoldTime == 0 &&
        totalAccuracy == 0 &&
        reactionTimes.isEmpty) return '0';

    return '1';
  }

  double get averageReactionTime => reactionTimes.isEmpty
      ? 0
      : reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;

  Map<String, dynamic> toJson(Points? pointsComponent) {
    return {
      'Tempo de reação médio': averageReactionTime,
      'Tempo de jogo': DateTime.now().difference(sessionStartTime).inSeconds,
      'Total de jogos na mesma sessão': totalGames,
      'Total de pontos': pointsComponent!.getTotalPoints(),
      'Tempo de pressão médio': getAverageHoldTime(),
      'Precisão média dos toques': getAverageAccuracy(),
    };
  }

  Map<String, dynamic> toJsonFlag() {
    return {
      'Causa do fim do jogo': _determineCauseOfLose(),
      'Ação do usuário': _determineAction(),
    };
  }

  Map<String, dynamic> toJsonFlagDescription() {
    return {
      'Causa do fim do jogo-0':
          'das partidas, o paciente perdeu mais vidas por conta do tempo',
      'Causa do fim do jogo-1':
          'das partidas, paciente perdeu mais vidas por conta de selecionar a peça errada',
      'Ação do usuário-0': 'das partidas, paciente não realizou nenhuma ação',
      'Ação do usuário-1': 'das partidas, paciente realizou alguma ação',
    };
  }
}
