import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';

class GameSelectionField extends StatefulWidget {
  final int? patientId;
  final Function(String) onGameSelected;

  const GameSelectionField(
      {super.key, required this.patientId, required this.onGameSelected});

  @override
  GameSelectionFieldState createState() => GameSelectionFieldState();
}

class GameSelectionFieldState extends State<GameSelectionField> {
  final JsonDataDao _jsonDataDao = JsonDataDao();
  List<String> _games = [];
  String? _selectedGame;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _fetchGames();
    }
  }

  void _fetchGames() async {
    List<String> games = await _jsonDataDao
        .getUniqueGamesByPatientId((widget.patientId).toString());
    setState(() {
      _games = games;
    });
  }

  @override
  void didUpdateWidget(covariant GameSelectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _fetchGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedGame,
      hint: const Text('Selecione o jogo'),
      isExpanded: true, // Ensures the dropdown fits the available width
      items: _games.map((String game) {
        return DropdownMenuItem<String>(
          value: game,
          child: Text(game),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGame = newValue;
        });
        if (newValue != null) {
          widget.onGameSelected(newValue);
        }
      },
    );
  }
}
