import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/models/form_model.dart';
import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/screens/components/patient.dart';
import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  FormScreen({required this.formChangeNotifier});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formDao = FormDao();
  final _patientDao = PatientDao();

  String _name = 'Perguntas';

  void _handleCardOptionTap(String name) {
    setState(() {
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _patientDao.filterByName(textEditingValue.text);
              },
              onSelected: (String selection) {
                print('You just selected $selection');
              },
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CardOption('Perguntas', Icons.help,
                          onTap: _handleCardOptionTap),
                      const SizedBox(width: 8),
                      CardOption('Jogos', Icons.games,
                          onTap: _handleCardOptionTap),
                      const SizedBox(width: 8),
                      CardOption('Sons', Icons.volume_up,
                          onTap: _handleCardOptionTap),
                      const SizedBox(width: 8),
                      CardOption('Dados', Icons.data_usage,
                          onTap: _handleCardOptionTap),
                    ],
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: [
                      if (_name == 'Perguntas') ...[
                        // Code for displaying questions
                      ],
                      if (_name == 'Jogos') ...[
                        // Code for displaying games
                      ],
                      if (_name == 'Sons') ...[
                        // Code for displaying sounds
                      ],
                      if (_name == 'Dados') ...[
                        // Code for displaying data
                      ],
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _formDao.insertForm({
                          'name': _name,
                        });
                        widget.formChangeNotifier.value++;
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    },
                    child: const Text('Submit'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
