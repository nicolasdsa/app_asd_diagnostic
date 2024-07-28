import 'package:flutter/material.dart';

class HashDataScreen extends StatelessWidget {
  final Map<String, dynamic> hashData;

  const HashDataScreen({required this.hashData});

  @override
  Widget build(BuildContext context) {
    // Convertemos a lista dinâmica para uma lista de mapas de strings
    final List<Map<String, String>> games = List<Map<String, String>>.from(
      hashData['games'].map(
        (game) =>
            {'name': game['name'] as String, 'link': game['link'] as String},
      ),
    );

    final String idPatient = hashData['id_patient'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dados da Hash'),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/hitRun',
                  arguments: {'idPatient': idPatient},
                );
              },
              child: Text(game['name'] ?? 'Jogo ${index + 1}'),
            ),
          );
        },
      ),
    );
  }
}
