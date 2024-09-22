import 'dart:convert';

import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:flutter/material.dart';

class HashDataScreen extends StatefulWidget {
  final String hash;

  const HashDataScreen({super.key, required this.hash});

  @override
  State<HashDataScreen> createState() => _HashDataScreenState();
}

class _HashDataScreenState extends State<HashDataScreen> {
  List<Map<String, dynamic>> gameDetails = [];
  String idPatient = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    final hashAccessDao = HashAccessDao();
    final gameDao = GameDao();

    final hashData = await hashAccessDao.getOne(widget.hash);
    final gameLinks = hashData!['gameLinks'];
    idPatient = gameLinks.split('-')[0];
    final games = gameLinks.split('-')[1].split(', ');

    for (var game in games) {
      print(jsonDecode(game));
      final gameDecode = jsonDecode(game);
      print(gameDecode["Id"]);
      final gameData = await gameDao.getOne(gameDecode["Id"].toString());
      final link = gameData['link'];
      gameDetails.add({
        'link': link,
        'properties': gameDecode,
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dados da Hash'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados da Hash'),
      ),
      body: ListView.builder(
        itemCount: gameDetails.length,
        itemBuilder: (context, index) {
          print(gameDetails[index]);
          final game = gameDetails[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  game['link'],
                  arguments: {
                    'idPatient': idPatient,
                    'properties': game['properties'],
                  },
                );
              },
              child: Text('Jogo ${index + 1}'),
            ),
          );
        },
      ),
    );
  }
}
