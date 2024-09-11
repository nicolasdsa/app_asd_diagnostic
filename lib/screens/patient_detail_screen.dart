import 'dart:io';

import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:app_asd_diagnostic/screens/components/patient_details.dart';
import 'package:app_asd_diagnostic/screens/form_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';

class PatientDetailScreen extends StatelessWidget {
  final int patientId;
  final ValueNotifier<int> valueNotifier = ValueNotifier<int>(0);

  PatientDetailScreen({Key? key, required this.patientId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchPatientDetails() async {
    final patientDao = PatientDao();
    final formDao = FormDao();

    final patient = await patientDao.getPatientById(patientId);
    final forms = await formDao.getFormsByPatientId(patientId);

    return {
      'patient': patient,
      'forms': forms,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes do paciente'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPatientDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado'));
          } else {
            final patient = snapshot.data!['patient'];
            final forms = snapshot.data!['forms'] as List<FormUser>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 10.0), // Adiciona espaço abaixo do Container
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Cor da borda
                            width: 1.0, // Largura da borda
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: patient['photo'].isNotEmpty
                                ? FileImage(File(patient['photo']))
                                    as ImageProvider
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient['name'],
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                    '${patient['age']} anos, ${patient['gender']}',
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text('Informações Médicas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 10),
                    Text('Descrição',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${patient['description']}',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    Text('Diagnóstico',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${patient['diagnosis']}',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Formulários',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FormScreen(idPatient: patient['id']),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text(
                              'Criar formulário',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (forms.isNotEmpty) ...[
                      ...forms.map((form) {
                        return form;
                      }).toList(),
                    ] else ...[
                      const Text('Nenhum formulário encontrado',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
