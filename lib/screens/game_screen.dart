import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:flutter/material.dart';

class GameView extends StatelessWidget {
  final int id;
  final _gameDao = GameDao();

  GameView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _gameDao
          .getAllGamesWithObjectives(id.toString()), // Fetch game information
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('O jogo não foi encontrado'));
        } else {
          final game = snapshot.data!;
          return Scaffold(
              appBar: CustomAppBar(title: game['name']),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.asset(game['path']),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.black.withOpacity(0.5),
                              child: Text(
                                game['name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Sobre o jogo',
                                style:
                                    Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 16),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text('${game['long_description']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Habilidades cognitivas testadas',
                                style:
                                    Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 8),
                            for (var objective in game['objectives'])
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• $objective',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(fontSize: 16)),
                                  const SizedBox(height: 8),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        }
      },
    );
  }
}
