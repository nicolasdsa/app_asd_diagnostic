// patients_screen.dart
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/screens/components/patient.dart';
import 'package:app_asd_diagnostic/screens/patient_detail_screen.dart';
import 'package:app_asd_diagnostic/screens/patients_create_screen.dart';
import 'package:flutter/material.dart';

class PatientScreen extends StatefulWidget {
  final ValueNotifier<int> patientChangeNotifier;

  const PatientScreen({required this.patientChangeNotifier, Key? key})
      : super(key: key);

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final _patientDao = PatientDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        automaticallyImplyLeading: false, // Remove o botão de voltar
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.patientChangeNotifier,
        builder: (context, value, child) {
          return FutureBuilder<List<Patient>>(
            future: _patientDao.getAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Nenhum paciente encontrado'),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final patient = snapshot.data![index];
                    return ListTile(
                      title: Text(patient.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PatientDetailScreen(patientId: patient.id),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientCreateScreen(
                  patientChangeNotifier: widget.patientChangeNotifier),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
