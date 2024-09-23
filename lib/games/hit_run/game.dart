import 'package:app_asd_diagnostic/db/hit_run_objects_dao.dart';
import 'package:app_asd_diagnostic/db/patient_object_hit_run_dao.dart';
import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          GameWidget(
            game: widget.game,
            overlayBuilderMap: {
              'MenuOverlay': (context, game) {
                final hitRunGame = game as HitRun;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Menu Inicial',
                          style: TextStyle(fontSize: 24)),
                      ElevatedButton(
                        onPressed: () {
                          hitRunGame.startGame();
                        },
                        child: const Text('Start Game'),
                      ),
                      // Novo botão "Loja"
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isShopVisible = true;
                          });
                        },
                        child: const Text('Loja'),
                      ),
                    ],
                  ),
                );
              },
              'PauseOverlay': (context, game) {
                final hitRunGame = game as HitRun;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Game Paused', style: TextStyle(fontSize: 24)),
                      ElevatedButton(
                        onPressed: () {
                          hitRunGame.resumeGame();
                        },
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                );
              },
            },
          ),
          if (_isShopVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Loja',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: HitRunObjectDao().getAll(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final hitRunObjects = snapshot.data!;
                          return ListView.builder(
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
                                  return ListTile(
                                    title: Text(
                                      object['name'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    tileColor: isAssigned
                                        ? Colors.green
                                        : Colors
                                            .white10, // Cor se for o objeto do paciente
                                    onTap: () {
                                      assignObjectToPatient(
                                          object['id'], widget.idPatient);
                                      setState(() {
                                        _isShopVisible = false;
                                      });
                                    },
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
                      child: const Text('Fechar Loja'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Verifica se o objeto está associado ao paciente
  Future<bool> isObjectAssignedToPatient(int objectId, int patientId) async {
    final patientObject = PatientObjectHitRunDao();
    final result = await patientObject.getOne(objectId, patientId);
    return result.isNotEmpty;
  }

  // Associa o objeto ao paciente
  Future<int> assignObjectToPatient(int objectId, int patientId) async {
    final patientObject = PatientObjectHitRunDao();
    return await patientObject.update(
        patientId, {'hit_run_object_id': objectId, 'patient_id': patientId});
  }
}
