import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/screens/components/patient.dart';
import 'package:app_asd_diagnostic/screens/patients_create_screen.dart';
import 'package:flutter/material.dart';

class PatientScreen extends StatefulWidget {
  final ValueNotifier<int> patientChangeNotifier;

  const PatientScreen({required this.patientChangeNotifier, Key? key})
      : super(key: key);

  @override
  State<PatientScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<PatientScreen> {
  final _patientDao = PatientDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
      ),
      body: ValueListenableBuilder(
        valueListenable: widget.patientChangeNotifier,
        builder: (context, value, child) {
          return FutureBuilder<List<Patient>>(
            future: _patientDao.getAll(),
            builder: (context, snapshot) {
              List<Patient>? items = snapshot.data;
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text('Carregando'),
                      ],
                    ),
                  );

                case ConnectionState.waiting:
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text('Carregando'),
                      ],
                    ),
                  );
                case ConnectionState.active:
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text('Carregando'),
                      ],
                    ),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    // Print the error to the console
                    print('Error: ${snapshot.error}');
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData && items != null) {
                    if (items.isNotEmpty) {
                      return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return items[index];
                          });
                    }
                    return const Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 128,
                        ),
                        Text(
                          'Não há nenhum paciente cadastrado',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ));
                  }

                  return const Text('Erro ao carregar os pacientes');
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
                    patientChangeNotifier: widget.patientChangeNotifier)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
