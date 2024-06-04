import 'dart:convert';

import 'package:app_asd_diagnostic/db/database.dart';
import 'package:flutter/material.dart';

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
      final form = result.first;
      final gameLinks = json.decode(form['gameLinks']) as List<dynamic>;
      return {
        'id_patient': form['id_patient'],
        'gameLinks': gameLinks.cast<String>()
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

class HashDataScreen extends StatelessWidget {
  final Map<String, dynamic> hashData;

  const HashDataScreen({required this.hashData});

  @override
  Widget build(BuildContext context) {
    final gameLinks = hashData['gameLinks'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dados da Hash'),
      ),
      body: ListView.builder(
        itemCount: gameLinks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Jogo ${index + 1}'),
            subtitle: Text(gameLinks[index]),
            onTap: () {
              Navigator.pushNamed(context, gameLinks[index]);
            },
          );
        },
      ),
    );
  }
}
