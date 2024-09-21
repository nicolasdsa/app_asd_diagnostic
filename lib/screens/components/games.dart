import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';
import 'package:flutter/material.dart';

class Games extends StatelessWidget {
  final List<List<dynamic>> _avaliarComportamentoElements;
  final Function(String, int) _addElementToAvaliarComportamento;

  const Games({
    Key? key,
    required List<List<dynamic>> avaliarComportamentoElements,
    required Function(String, int) addElementToAvaliarComportamento,
  })  : _avaliarComportamentoElements = avaliarComportamentoElements,
        _addElementToAvaliarComportamento = addElementToAvaliarComportamento,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: GameDao().getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final items = snapshot.data ?? [];
          return Column(
            children: items.map((item) {
              ValueNotifier<bool> isIncludedInAnalysisGame = ValueNotifier(
                _avaliarComportamentoElements
                    .any((element) => element[1] == item['id']),
              );

              return GestureDetector(
                onTap: () {
                  _addElementToAvaliarComportamento('games', item['id']);
                  isIncludedInAnalysisGame.value =
                      !isIncludedInAnalysisGame.value;
                },
                child: ValueListenableBuilder<bool>(
                  valueListenable: isIncludedInAnalysisGame,
                  builder: (context, isIncluded, _) {
                    return GameComponent(
                      item['name'],
                      item['link'],
                      id: item['id'],
                      backgroundColor: isIncluded ? Colors.green : Colors.white,
                    );
                  },
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
