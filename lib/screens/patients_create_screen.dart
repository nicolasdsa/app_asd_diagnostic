import 'dart:io';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PatientCreateScreen extends StatefulWidget {
  final ValueNotifier<int> patientChangeNotifier;
  final int? patientId; // Adicionando o id do paciente

  const PatientCreateScreen(
      {super.key, required this.patientChangeNotifier, this.patientId});

  @override
  PatientsCreateScreenState createState() => PatientsCreateScreenState();
}

class PatientsCreateScreenState extends State<PatientCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientDao = PatientDao();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _diagnosisController = TextEditingController();
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _loadPatientData(widget.patientId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _descriptionController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData(int patientId) async {
    final patientData = await _patientDao.getPatientById(patientId);
    _nameController.text = patientData['name'];
    _ageController.text = patientData['age'].toString();
    _genderController.text = patientData['gender'];
    _descriptionController.text = patientData['description'];
    _diagnosisController.text = patientData['diagnosis'];
    if (patientData['photo'] != null && patientData['photo'].isNotEmpty) {
      _selectedPhoto = File(patientData['photo']);
    }
    setState(() {});
  }

  Future<void> _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPhoto = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cadastro de Pacientes'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Escreva o nome do paciente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text(
                  'Idade',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 12.0),
                // Campo de Idade
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Idade',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Escreva a idade do paciente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Gênero', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                DropdownButtonFormField<String>(
                  value: _genderController.text.isNotEmpty
                      ? _genderController.text
                      : null,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  hint: Text('Selecione o gênero',
                      style: Theme.of(context).textTheme.labelSmall),
                  items: ['Masculino', 'Feminino', 'Outro'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: Theme.of(context).textTheme.labelSmall),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _genderController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escolha o gênero do paciente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Descrição',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 55),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Escreva a descrição do paciente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Diagnóstico',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(
                    labelText: 'Possível diagnóstico',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 55),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Escreva o diagnóstico do paciente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Text('Foto', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    if (_selectedPhoto != null)
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                            image: FileImage(_selectedPhoto!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.photo_camera),
                      ),
                    ElevatedButton(
                      onPressed: _pickPhoto,
                      child: const Text(
                        'Escolher Foto',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (widget.patientId == null) {
                        final patientId = await _patientDao.insert({
                          'name': _nameController.text,
                          'age': _ageController.text,
                          'gender': _genderController.text,
                          'photo': _selectedPhoto?.path ?? '',
                          'description': _descriptionController.text,
                          'diagnosis': _diagnosisController.text,
                        });
                        widget.patientChangeNotifier.value++;
                        Navigator.pushReplacementNamed(
                          context,
                          '/patient',
                          arguments: {'patientId': patientId.toString()},
                        );
                      } else {
                        await _patientDao.update(widget.patientId!, {
                          'name': _nameController.text,
                          'age': _ageController.text,
                          'gender': _genderController.text,
                          'photo': _selectedPhoto?.path ?? '',
                          'description': _descriptionController.text,
                          'diagnosis': _diagnosisController.text,
                        });
                        widget.patientChangeNotifier.value++;
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        widget.patientId == null
                            ? 'Salvar Paciente'
                            : 'Editar Paciente',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
