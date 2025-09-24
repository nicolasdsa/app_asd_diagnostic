// lib/games/go_no_go/widgets/menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoNoGoMenu extends StatelessWidget {
  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;

  const GoNoGoMenu({
    super.key,
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Go/No-Go Challenge', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/myo_connection', // Mude a rota aqui!
                  arguments: {
                    'id': id,
                    'idPatient': idPatient,
                    'properties': properties,
                  },
                );
              },
              child: const Text('Iniciar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}
