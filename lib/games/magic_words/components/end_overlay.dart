import 'package:flutter/material.dart';
import 'package:flame/game.dart' as flame;
import 'package:app_asd_diagnostic/games/magic_words/magic_words.dart';

class MagicWordsEndOverlay extends StatelessWidget {
  final JogoFormaPalavrasGame game;
  const MagicWordsEndOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/wordsAdventureMenu',
          (Route<dynamic> route) => false,
          arguments: {
            'idPatient': game.idPatient,
            'properties': game.properties,
            'id': game.id,
          },
        );
      },
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título de parabéns
            Text(
              'Parabéns!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Mensagem de conclusão
            Text(
              'Você completou todas as palavras!\nToque em qualquer lugar para voltar ao menu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
