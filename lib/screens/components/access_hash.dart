import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/screens/hash_data_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessHashComponent extends StatefulWidget {
  const AccessHashComponent({super.key});

  @override
  AccessHashComponentState createState() => AccessHashComponentState();
}

class AccessHashComponentState extends State<AccessHashComponent> {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isHash', true);
      await prefs.setString('hash', hash);
      await prefs.setBool('isLoggedIn', false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HashDataScreen(hash: hash),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Hash inválida. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Hash', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 12.0),
        TextFormField(
            controller: _hashController,
            decoration: InputDecoration(
              labelText: 'Hash',
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              labelStyle: const TextStyle(fontSize: 12),
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Digite o hash';
              }
              return null;
            }),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitHash,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const SizedBox(
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.key,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
