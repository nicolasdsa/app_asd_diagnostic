import 'package:app_asd_diagnostic/screens/components/export_button.dart';
import 'package:app_asd_diagnostic/screens/components/game_selection_field.dart';
import 'package:app_asd_diagnostic/screens/components/patient_search_field.dart';
import 'package:flutter/material.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int? _selectedPatientId;
  String? _selectedGame;

  void _setSelectedPatientId(int id) {
    setState(() {
      _selectedPatientId = id;
    });
  }

  void _setSelectedGame(String game) {
    setState(() {
      _selectedGame = game;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PatientSearchField(
              onPatientSelected: _setSelectedPatientId,
            ),
            const SizedBox(height: 16.0),
            if (_selectedPatientId != null)
              GameSelectionField(
                patientId: _selectedPatientId!,
                onGameSelected: _setSelectedGame,
              ),
            const SizedBox(height: 16.0),
            if (_selectedPatientId != null && _selectedGame != null)
              ExportButton(
                patientId: _selectedPatientId!,
                game: _selectedGame!,
              ),
          ],
        ),
      ),
    );
  }
}
