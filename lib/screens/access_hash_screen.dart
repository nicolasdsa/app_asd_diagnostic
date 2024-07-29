import 'package:app_asd_diagnostic/screens/hash_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/database.dart';
import 'package:app_asd_diagnostic/db/game_dao.dart';

class AccessHashScreen extends StatefulWidget {
  @override
  _AccessHashScreenState createState() => _AccessHashScreenState();
}

class _AccessHashScreenState extends State<AccessHashScreen> {
  final TextEditingController _hashController = TextEditingController();
  String _errorMessage = '';

  Future<Map<String, dynamic>> _getHashData(String hash) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'hash_access',
      where: 'accessHash = ?',
      whereArgs: [hash],
    );

    if (result.isNotEmpty) {
      final hashLinks = result.first;
      final gameLinks = hashLinks['gameLinks'].split('-');
      final gamesHash = gameLinks[1].split(',');
      final idPatient = gameLinks[0];

      // Obtemos os detalhes dos jogos
      final gameDao = GameDao();
      final games = await gameDao.getAllHash();

      // Mapeamos os links dos jogos para obter os nomes correspondentes
      final gameNames = gamesHash.map((id) {
        try {
          final game = games.firstWhere((game) => game['id'].toString() == id);
          return {'name': game['name'], 'link': game['link']};
        } catch (e) {
          return {'name': 'Unknown', 'link': ''};
        }
      }).toList();

      print(gameNames);

      return {
        'id_patient': idPatient,
        'games': gameNames,
      };
    } else {
      throw Exception('Hash not found');
    }
  }

  void _submitHash() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      final hashData = await _getHashData(_hashController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HashDataScreen(hashData: hashData),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Hash inválida. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acessar com Hash'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _hashController,
              decoration: InputDecoration(
                labelText: 'Insira a Hash',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitHash,
              child: Text('Acessar'),
            ),
          ],
        ),
      ),
    );
  }
}
