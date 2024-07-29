import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';

class GameSelectionField extends StatefulWidget {
  final int patientId;
  final Function(String) onGameSelected;

  GameSelectionField({required this.patientId, required this.onGameSelected});

  @override
  _GameSelectionFieldState createState() => _GameSelectionFieldState();
}

class _GameSelectionFieldState extends State<GameSelectionField> {
  final JsonDataDao _jsonDataDao = JsonDataDao();
  List<String> _games = [];
  String? _selectedGame;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  void _fetchGames() async {
    List<String> games = await _jsonDataDao
        .getUniqueGamesByPatientId((widget.patientId).toString());
    setState(() {
      _games = games;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedGame,
      hint: Text('Select Game'),
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
