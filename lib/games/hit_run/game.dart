import 'package:app_asd_diagnostic/db/hit_run_objects_dao.dart';
import 'package:app_asd_diagnostic/db/patient_object_hit_run_dao.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';

class GameScreen extends StatefulWidget {
  final HitRun game;
  final int idPatient;

  GameScreen({required this.game, required this.idPatient});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isShopVisible = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      body: Stack(
        children: [
          // O jogo
          GameWidget(
            game: widget.game,
            overlayBuilderMap: {
              'MenuOverlay': (context, game) {
                final hitRunGame = game as HitRun;
                return Stack(
                  children: [
                    // Imagem de fundo por cima do jogo
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/hit_run/hit_run_logo.jpeg', // Caminho da imagem de fundo
                        fit: BoxFit.fill, // Para preencher toda a tela
                      ),
                    ),
                    // Botões por cima da imagem
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                hitRunGame
                                    .startGame(); // Inicia o jogo e oculta a overlay
                              },
                              child: const Text('Iniciar Jogo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'PressStart2P-Regular',
                                  )),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isShopVisible = true;
                                });
                              },
                              child: const Text('Loja',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'PressStart2P-Regular',
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
              'PauseOverlay': (context, game) {
                final hitRunGame = game as HitRun;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Game Paused',
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                      ElevatedButton(
                        onPressed: () {
                          hitRunGame.resumeGame(); // Retoma o jogo
                        },
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                );
              },
            },
          ),
          // Loja visível por cima do jogo, se ativada
          if (_isShopVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Loja',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'PressStart2P-Regular',
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: HitRunObjectDao().getAll(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final hitRunObjects = snapshot.data!;
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: hitRunObjects.length,
                            itemBuilder: (context, index) {
                              final object = hitRunObjects[index];
                              return FutureBuilder<bool>(
                                future: isObjectAssignedToPatient(
                                    object['id'], widget.idPatient),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  final isAssigned = snapshot.data!;
                                  return GestureDetector(
                                    onTap: () {
                                      assignObjectToPatient(
                                          object['id'], widget.idPatient);
                                      setState(() {
                                        _isShopVisible = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isAssigned
                                            ? Colors.green
                                            : Colors.white10,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isAssigned
                                              ? Colors.yellow
                                              : Colors.white30,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Exibição da imagem do objeto
                                          Expanded(
                                            child: Image.asset(
                                              object['path'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          // Nome do objeto
                                          Text(
                                            object['name'],
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontFamily:
                                                    'PressStart2P-Regular',
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isShopVisible = false;
                        });
                      },
                      child: const Text('Fechar Loja',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'PressStart2P-Regular',
                          )),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> isObjectAssignedToPatient(int objectId, int patientId) async {
    final patientObject = PatientObjectHitRunDao();
    final result = await patientObject.getOne(objectId, patientId);
    return result.isNotEmpty;
  }

  Future<int> assignObjectToPatient(int objectId, int patientId) async {
    final patientObject = PatientObjectHitRunDao();
    return await patientObject.update(
        patientId, {'hit_run_object_id': objectId, 'patient_id': patientId});
  }
}
