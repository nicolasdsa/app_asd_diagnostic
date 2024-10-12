import 'package:app_asd_diagnostic/screens/components/login.dart';
import 'package:app_asd_diagnostic/screens/login_and_hash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialScreen extends StatefulWidget {
  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('inf', '');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginAndHashScreen()),
      (route) => false, // Remove todas as rotas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a orientação como retrato
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tela inicial',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bem vindo de volta, Nicolas!"),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/questions');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue,
                child: const Text(
                  'Minhas questões',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/sounds');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.red,
                child: const Text(
                  'Meus sons',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/games');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green,
                child: const Text(
                  'Jogos disponíveis',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey,
                child: const Text(
                  'Minha consultas',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
