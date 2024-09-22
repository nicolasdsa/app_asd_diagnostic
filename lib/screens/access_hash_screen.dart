import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/screens/hash_data_screen.dart';
import 'package:flutter/material.dart';

class AccessHashScreen extends StatefulWidget {
  @override
  _AccessHashScreenState createState() => _AccessHashScreenState();
}

class _AccessHashScreenState extends State<AccessHashScreen> {
  final TextEditingController _hashController = TextEditingController();
  String _errorMessage = '';

  Future<String?> _getHashData(String hash) async {
    final hashAccessDao = HashAccessDao();
    final result = await hashAccessDao.getOne(hash);

    if (result != null) {
      return hash;
    }

    return null;
  }

  void _submitHash() async {
    final hash = await _getHashData(_hashController.text);

    if (hash != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HashDataScreen(hash: hash),
        ),
      );
    }

    setState(() {
      _errorMessage = 'Hash inválida. Tente novamente.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acessar com Hash'),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitHash,
              child: const Text('Acessar'),
            ),
          ],
        ),
      ),
    );
  }
}
