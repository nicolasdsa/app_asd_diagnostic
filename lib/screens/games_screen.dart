import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:flutter/material.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  GamesScreenState createState() => GamesScreenState();
}

class GamesScreenState extends State<GamesScreen> {
  final GameDao _gameDao = GameDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Jogos Disponíveis'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _gameDao.getAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum jogo disponível'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/gameView',
                                arguments: snapshot.data![index]['id']);
                          },
                          child: GameComponent(
                            snapshot.data![index]['name'],
                            snapshot.data![index]['link'],
                            id: snapshot.data![index]['id'],
                            shortDescription: snapshot.data![index]
                                ['short_description'],
                            path: snapshot.data![index]['path'],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
