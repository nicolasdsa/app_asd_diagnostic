// lib/games/go_no_go/widgets/myo_connection_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/myo/myo_handler.dart';

class MyoConnectionScreen extends StatefulWidget {
  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;

  const MyoConnectionScreen({
    super.key,
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  @override
  State<MyoConnectionScreen> createState() => _MyoConnectionScreenState();
}

class _MyoConnectionScreenState extends State<MyoConnectionScreen> {
  final MyoHandler _myoHandler = MyoHandler();
  StreamSubscription? _poseSubscription;
  MyoPose _currentPose = MyoPose.unknown;

  // Gestos necessários para a calibração
  final List<MyoPose> _gesturesToPerform = [
    MyoPose.fist,
    MyoPose.waveIn,
    MyoPose.fingersSpread
  ];
  final Set<MyoPose> _gesturesCompleted = {};

  @override
  void initState() {
    super.initState();
    // Tenta conectar assim que a tela é carregada
    if (!_myoHandler.isConnected) {
      _myoHandler.connect();
    }
    // Ouve o stream de poses para a fase de calibração
    _poseSubscription = _myoHandler.poseStream.listen(_onPoseReceived);
  }

  @override
  void dispose() {
    _poseSubscription?.cancel();
    super.dispose();
  }

  void _onPoseReceived(MyoPose pose) {
    if (!mounted) return;

    setState(() {
      _currentPose = pose;
    });

    if (_gesturesToPerform.contains(pose) &&
        !_gesturesCompleted.contains(pose)) {
      setState(() {
        _gesturesCompleted.add(pose);
      });
      _myoHandler.vibrate(1); // Vibra para confirmar o gesto
    }

    // Se todos os gestos foram feitos, inicia o jogo
    if (_gesturesCompleted.length == _gesturesToPerform.length) {
      _startGame();
    }
  }

  void _startGame() {
    // Adiciona um pequeno delay para o usuário perceber que a calibração terminou
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/go_no_go_game', // Navega para o jogo, substituindo a tela atual
          arguments: {
            'id': widget.id,
            'idPatient': widget.idPatient,
            'properties': widget.properties,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // ValueListenableBuilder reage às mudanças de estado do MyoHandler
        child: ValueListenableBuilder<MyoConnectionState>(
          valueListenable: _myoHandler.connectionState,
          builder: (context, state, child) {
            switch (state) {
              case MyoConnectionState.scanning:
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Procurando bracelete Myo...",
                        style: TextStyle(fontSize: 22)),
                  ],
                );
              case MyoConnectionState.connecting:
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Conectando...", style: TextStyle(fontSize: 22)),
                  ],
                );
              case MyoConnectionState.connected:
                // Se conectado, mostra a UI de calibração
                return _buildCalibrationUI();
              case MyoConnectionState.failed:
              case MyoConnectionState.disconnected:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    const Text("Falha na conexão com o Myo.",
                        style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _myoHandler.connect(),
                      child: const Text("Tentar Novamente"),
                    )
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCalibrationUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Calibração",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text("Realize os seguintes gestos para começar:",
            style: TextStyle(fontSize: 20)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _gesturesToPerform.map((gesture) {
            return _buildGestureChip(
              gesture: gesture,
              isCompleted: _gesturesCompleted.contains(gesture),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        Text("Gesto Atual: ${_currentPose.name}",
            style: const TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildGestureChip(
      {required MyoPose gesture, required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        avatar: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.white : Colors.blue,
        ),
        label: Text(gesture.name,
            style: TextStyle(color: isCompleted ? Colors.white : Colors.black)),
        backgroundColor: isCompleted ? Colors.green : Colors.grey.shade300,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
