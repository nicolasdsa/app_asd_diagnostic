import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuInicial extends StatefulWidget {
  final int id;
  final String idPatient;
  final Map<String, dynamic> properties;

  const MenuInicial({
    super.key,
    required this.id,
    required this.idPatient,
    required this.properties,
  });

  @override
  State<MenuInicial> createState() => _MenuInicialState();
}

class _MenuInicialState extends State<MenuInicial> {
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

  void _showInstructionsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              children: [
                // Imagem de fundo
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/words_adventure/icons/background.png', // Caminho da imagem de fundo
                    fit: BoxFit.cover,
                  ),
                ),
                // Conteúdo do modal
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/words_adventure/icons/hex_gold.png', // Caminho da imagem correta
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          const Text('Imagem quando está correto'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/words_adventure/icons/hex_pink.png', // Caminho da imagem errada
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          const Text('Imagem quando está errado'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/words_adventure/icons/hex_white.png', // Caminho da imagem padrão
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 10),
                          const Text('Imagem padrão'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Clique em qualquer lugar para fechar.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              'assets/images/words_adventure/icons/menu.png',
              fit: BoxFit.cover, // Ajusta a imagem para cobrir toda a tela
            ),
          ),
          // GIF de fundo animado
          if (!_isGifCompleted)
            Positioned.fill(
              child: Image.asset(
                'assets/images/words_adventure/icons/menu.gif',
                fit: BoxFit.cover, // Ajusta a imagem para cobrir toda a tela
              ),
            ),
          // Botão de ajuda no canto superior direito
          Positioned(
            top: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showInstructionsModal(context);
              },
              child: const Text('Ajuda'),
            ),
          ),
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
                              colors: [Colors.purple.shade100, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/word_box',
                                arguments: {
                                  'id': widget.id,
                                  'idPatient': widget.idPatient,
                                  'properties': widget.properties,
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
