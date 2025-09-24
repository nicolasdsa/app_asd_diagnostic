// lib/games/go_no_go/go_no_go_game.dart
import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/myo/myo_handler.dart'; // Importe o handler
import 'components/target.dart';

class GoNoGoGame extends FlameGame {
  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;

  final MyoHandler _myoHandler = MyoHandler();
  late final Target _target;
  Timer? _stimulusTimer;
  Stopwatch _reactionTimer = Stopwatch();

  GoNoGoGame({
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Adiciona o alvo no centro
    _target = Target()..position = size / 2;
    add(_target);

    // Inicia o loop do jogo
    _startTrial();

    // Ouve os gestos do Myo
    _myoHandler.poseStream.listen(_onPose);
  }

  void _startTrial() {
    _target.reset();

    // Tempo aleatório antes do estímulo
    final waitTime = 1.5 + Random().nextDouble() * 2; // entre 1.5 e 3.5s
    _stimulusTimer = Timer(waitTime, onTick: () {
      if (Random().nextBool()) {
        _target.setGo();
        // Toca som agudo
      } else {
        _target.setNoGo();
        // Toca som grave
      }
      _reactionTimer.start();
    });
    _stimulusTimer?.start();
  }

  void _onPose(MyoPose pose) {
    if (_reactionTimer.isRunning) {
      if (_target.state == TargetState.go) {
        if (pose == MyoPose.fist) {
          // Gesto de "Go"
          _handleCorrectGo();
        }
      } else if (_target.state == TargetState.noGo) {
        if (pose != MyoPose.rest) {
          // Qualquer movimento é um erro
          _handleIncorrectNoGo();
        }
      }
    }
  }

  void _handleCorrectGo() {
    _reactionTimer.stop();
    print('Acerto! Latência: ${_reactionTimer.elapsedMilliseconds}ms');
    // Feedback visual/auditivo de acerto
    _endTrial();
  }

  void _handleIncorrectNoGo() {
    _reactionTimer.stop();
    print('Erro! Movimento em um "No-Go"');
    // Feedback visual/auditivo de erro de inibição
    _endTrial();
  }

  void _endTrial() {
    _reactionTimer.reset();
    _stimulusTimer?.stop();

    // Pausa antes de iniciar a próxima rodada
    Future.delayed(const Duration(seconds: 2), _startTrial);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _stimulusTimer?.update(dt);

    // Lógica para erro de inação em "Go"
    if (_target.state == TargetState.go &&
        _reactionTimer.elapsedMilliseconds > 2000) {
      print('Erro! Sem resposta para o "Go"');
      _endTrial();
    }
  }

  @override
  void onRemove() {
    _stimulusTimer?.stop();
    super.onRemove();
  }
}
