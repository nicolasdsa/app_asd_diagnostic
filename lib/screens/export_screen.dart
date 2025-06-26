import 'package:app_asd_diagnostic/screens/components/export_button.dart';
import 'package:app_asd_diagnostic/screens/components/game_selection_field.dart';
import 'package:app_asd_diagnostic/screens/components/import_button.dart';
import 'package:app_asd_diagnostic/screens/components/json_file_picker.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
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
  Map<String, dynamic>? _jsonData;

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

  void _setJsonData(Map<String, dynamic> jsonData) {
    setState(() {
      _jsonData = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dados', showBackArrow: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Escolha o paciente que vocẽ quer manipular os dados',
                  style: Theme.of(context).textTheme.labelMedium),
              PatientSearchField(
                onPatientSelected: _setSelectedPatientId,
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exportar dados',
                        style: Theme.of(context).textTheme.titleMedium),
                    Opacity(
                      opacity: _selectedPatientId != null ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: _selectedPatientId == null,
                        child: GameSelectionField(
                          patientId: _selectedPatientId,
                          onGameSelected: _setSelectedGame,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Opacity(
                      opacity:
                          _selectedPatientId != null && _selectedGame != null
                              ? 1.0
                              : 0.5,
                      child: IgnorePointer(
                          ignoring: _selectedPatientId == null ||
                              _selectedGame == null,
                          child: ExportButton(
                            patientId: _selectedPatientId,
                            game: _selectedGame,
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Importar dados',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16.0),
                      Text('Arquivo JSON',
                          style: Theme.of(context).textTheme.labelSmall),
                      Opacity(
                          opacity: _selectedPatientId != null ? 1.0 : 0.5,
                          child: IgnorePointer(
                              ignoring: _selectedPatientId == null,
                              child: JsonFilePicker(
                                  onJsonSelected: _setJsonData))),
                      const SizedBox(height: 16.0),
                      Opacity(
                        opacity: _selectedPatientId != null && _jsonData != null
                            ? 1.0
                            : 0.5,
                        child: IgnorePointer(
                            ignoring:
                                _selectedPatientId == null || _jsonData == null,
                            child: ImportButton(
                              patientId: _selectedPatientId,
                              jsonData: _jsonData,
                            )),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
