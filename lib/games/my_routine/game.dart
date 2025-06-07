import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuInicialMinhaRotina extends StatefulWidget {
  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;

  const MenuInicialMinhaRotina({
    super.key,
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  @override
  State<MenuInicialMinhaRotina> createState() => _MenuInicialMinhaRotinaState();
}

class _MenuInicialMinhaRotinaState extends State<MenuInicialMinhaRotina> {
  bool _isGifCompleted = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _startGifAnimation();
  }

  void _startGifAnimation() async {
    await Future.delayed(const Duration(seconds: 5)); // Duração do GIF
    setState(() {
      _isGifCompleted = true;
      _showButton = true; // Mostra o botão após o GIF
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define a orientação da tela como horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          // Imagem estática de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/my_routine/icons/menu.png',
              fit: BoxFit.cover, // Ajusta a imagem para cobrir toda a tela
            ),
          ),
          // GIF de fundo animado
          if (!_isGifCompleted)
            Positioned.fill(
              child: Image.asset(
                'assets/images/my_routine/icons/menu_2.gif',
                fit: BoxFit.cover, // Ajusta a imagem para cobrir toda a tela
              ),
            ),
          // Botão de ajuda no canto superior direito
          // Conteúdo do menu
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _showButton ? 1.0 : 0.0,
                        duration: const Duration(seconds: 1),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade100, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/routine',
                                arguments: {
                                  'id': widget
                                      .id, // Substitua pelo valor real de id
                                  'idPatient': widget
                                      .idPatient, // Substitua pelo valor real de idPatient
                                  'properties': widget
                                      .properties, // Substitua pelo mapa real de propriedades
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Iniciar Jogo',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
