import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';

class PatientSearchField extends StatefulWidget {
  final Function(int) onPatientSelected;

  PatientSearchField({required this.onPatientSelected});

  @override
  _PatientSearchFieldState createState() => _PatientSearchFieldState();
}

class _PatientSearchFieldState extends State<PatientSearchField> {
  final PatientDao _patientDao = PatientDao();
  String _selectedName = '';
  String _selectedPatientId = '';

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        final patients = await _patientDao.filterByName(textEditingValue.text);
        return patients.map((patient) => patient['name'] as String);
      },
      onSelected: (String selection) async {
        setState(() {
          _selectedName = selection;
        });
        final patients = await _patientDao.filterByName(_selectedName);
        if (patients.isNotEmpty) {
          _selectedPatientId = patients.first['id'].toString();
          widget.onPatientSelected(int.parse(_selectedPatientId));
        }
      },
    );
  }
}
