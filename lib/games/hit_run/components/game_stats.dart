class GameStats {
  List<double> reactionTimes = [];
  DateTime sessionStartTime;
  DateTime? gameStartTime;
  int totalGames = 0;

  GameStats() : sessionStartTime = DateTime.now();

  void startGame() {
    gameStartTime = DateTime.now();
    totalGames += 1;
  }

  void endGame() {
    if (gameStartTime != null) {
      gameStartTime = null;
      reactionTimes = [];
    }
  }

  void recordReactionTime(double reactionTime) {
    reactionTimes.add(reactionTime);
  }

  double get averageReactionTime => reactionTimes.isEmpty
      ? 0
      : reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;

  Map<String, dynamic> toJson() {
    return {
      'Tempo de reação médio': averageReactionTime,
      'Tempo de jogo': DateTime.now().difference(sessionStartTime).inSeconds,
      'Total de jogos na mesma sessão': totalGames,
    };
  }
}
