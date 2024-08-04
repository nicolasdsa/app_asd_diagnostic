import 'package:flutter/material.dart';

class HitRunMenuScreen extends StatelessWidget {
  final String idPatient;

  const HitRunMenuScreen({Key? key, required this.idPatient}) : super(key: key);

  void navigateToDifficultySelection(BuildContext context, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DifficultySelectionScreen(idPatient: idPatient, mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hit Run Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hit Run',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToDifficultySelection(context, 'visual'),
              child: const Text('Visual'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToDifficultySelection(context, 'sonoro'),
              child: const Text('Sonoro'),
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  final String idPatient;
  final String mode;

  const DifficultySelectionScreen({
    Key? key,
    required this.idPatient,
    required this.mode,
  }) : super(key: key);

  void startGame(BuildContext context, String difficulty) {
    Navigator.pushNamed(
      context,
      '/hitRun',
      arguments: {
        'idPatient': idPatient,
        'difficulty': difficulty,
        'mode': mode,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Difficulty')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Difficulty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startGame(context, 'easy'),
              child: const Text('Iniciar (Fácil)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startGame(context, 'difficult'),
              child: const Text('Iniciar (Difícil)'),
            ),
          ],
        ),
      ),
    );
  }
}
