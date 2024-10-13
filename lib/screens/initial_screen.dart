import 'package:app_asd_diagnostic/db/user.dart';
import 'package:app_asd_diagnostic/screens/login_and_hash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialScreen extends StatefulWidget {
  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  String _userName = 'Usuário';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('inf') ?? '';
    // Supondo que você tenha uma função para buscar o nome com base no ID
    final _userDao = UserDao();
    Map<String, dynamic> userName = await _userDao.getOneId(userId);
    setState(() {
      _userName = userName['name'];
    });
  }

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
            Text(
              "Bem vindo de volta, $_userName!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/questions');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.question_answer, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      'Perguntas',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Examine as questões',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/sounds');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      'Meus sons',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Explore seus sons',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/games');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videogame_asset, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      'Jogos disponíveis',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Veja os jogos',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
