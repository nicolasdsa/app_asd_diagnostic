class GameStats {
  DateTime sessionStartTime;
  int errorTaps = 0;
  int tipTaps = 0;
  int errorPhases = 0;
  int tipPhases = 0;
  int phasesPlayed = 0;
  Duration totalPhaseDuration = Duration.zero;
  void startNewPhase() => phasesPlayed++;
  GameStats() : sessionStartTime = DateTime.now();

  void addWrongLetters(int tapIndex) {
    errorTaps += tapIndex;
  }

  void addErrorPhase(int phaseIndex) {
    errorPhases += phaseIndex;
  }

  void addTip(int tipIndex) {
    tipTaps += tipIndex;
  }

  void addPhaseTime(Duration phaseTime) {
    totalPhaseDuration += phaseTime;
  }

  void addTipPhase(int phaseIndex) {
    tipPhases += phaseIndex;
  }

  Future<Map<String, dynamic>> toJson(String idPatient, id) async {
    return {
      'Tempo de jogo': DateTime.now().difference(sessionStartTime).inSeconds,
      'Total de letras selecionadas erradas': errorTaps,
      'Quantidade de fases que houveram erros': errorPhases,
      'Tempo médio nas fases': totalPhaseDuration.inSeconds / 7,
      'Total de dicas necessárias': tipTaps,
      'Quantidade de fases que foi necessário dicas': tipPhases
    };
  }

  Map<String, dynamic> toJsonFlag() {
    return {
      'Quantidade de fases que houveram erros': 0,
      'Quantidade de fases que foi necessário dicas': 0,
    };
  }

  Map<String, dynamic> toJsonFlagDescription() {
    return {
      'Quantidade de fases que houveram erros-0':
          'das 7 partidas, o paciente cometeu pelos menos 1 erro',
      'Quantidade de fases que foi necessário dicas-0':
          'das 7 partidas, paciente precisou de dicas em pelo menos 1 fase',
    };
  }
}
