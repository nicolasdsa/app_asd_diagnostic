import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:flutter/material.dart';

class PatientCreateScreen extends StatefulWidget {
  final ValueNotifier<int> patientChangeNotifier;

  PatientCreateScreen({required this.patientChangeNotifier});

  @override
  _PatientsCreateScreenState createState() => _PatientsCreateScreenState();
}

class _PatientsCreateScreenState extends State<PatientCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientDao = PatientDao();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Pacientes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Escreva o nome do paciente';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Escreva a idade do paciente';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gênero'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Escreva o sexo do paciente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final patientId = await _patientDao.insert({
                      'name': _nameController.text,
                      'age': _ageController.text,
                      'gender': _genderController.text,
                    });
                    widget.patientChangeNotifier.value++;
                    Navigator.pushReplacementNamed(
                      context,
                      '/patient',
                      arguments: {'patientId': patientId.toString()},
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
