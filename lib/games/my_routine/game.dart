import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuInicialMinhaRotina extends StatefulWidget {
  const MenuInicialMinhaRotina({super.key});

  @override
  State<MenuInicialMinhaRotina> createState() => _MenuInicialMinhaRotinaState();
}

class _MenuInicialMinhaRotinaState extends State<MenuInicialMinhaRotina> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to ASD Diagnostic Game',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/routine');
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
