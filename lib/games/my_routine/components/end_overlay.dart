import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:flutter/material.dart';

class EndOverlay extends StatelessWidget {
  final MyRoutine game;
  const EndOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Remove o overlay e retorna ao menu inicial
        game.overlays.remove('EndOverlay');
        // Supondo que sua rota inicial seja '/', ajuste se for diferente:
        Navigator.of(context)
            .pushReplacementNamed('/dailyRoutineMenu', arguments: {
          'idPatient': game.idPatient,
          'properties': game.properties,
          'id': game.id,
        });
      },
      child: Container(
        color: Colors.white, // fundo branco para bloquear tudo atrás
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Você completou a rotina do dia!\n\n'
                  'Parabéns por acompanhar todas as atividades.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Text(
                  'Toque em qualquer lugar para voltar ao menu inicial',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
