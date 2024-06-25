class GameStats {
  List<double> reactionTimes = [];
  DateTime sessionStartTime;
  DateTime? gameStartTime;
  int totalGames = 0;
  int totalGameTime = 0; // in seconds

  GameStats() : sessionStartTime = DateTime.now();

  void startGame() {
    gameStartTime = DateTime.now();
    totalGames += 1;
  }

  void endGame() {
    if (gameStartTime != null) {
      totalGameTime += DateTime.now().difference(gameStartTime!).inSeconds;
      gameStartTime = null;
    }
  }

  void recordReactionTime(double reactionTime) {
    reactionTimes.add(reactionTime);
  }

  double get averageReactionTime => reactionTimes.isEmpty
      ? 0
      : reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;

  double get averageGameTime =>
      totalGames == 0 ? 0 : totalGameTime / totalGames;

  Map<String, dynamic> toJson() {
    return {
      'Tempo de reação médio': averageReactionTime,
      'Tempo de jogo': DateTime.now().difference(sessionStartTime).inSeconds,
      'Tempo de jogo médio': averageGameTime,
      'Total de jogos': totalGames,
    };
  }
}
