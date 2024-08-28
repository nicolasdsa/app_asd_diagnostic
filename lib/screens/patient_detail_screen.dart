import 'package:app_asd_diagnostic/screens/components/patient_details.dart';
import 'package:app_asd_diagnostic/screens/form_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';
import 'package:app_asd_diagnostic/screens/form_detail_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final int patientId;
  final ValueNotifier<int> valueNotifier = ValueNotifier<int>(0);

  PatientDetailScreen({Key? key, required this.patientId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchPatientDetails() async {
    final patientDao = PatientDao();
    final formDao = FormDao();

    final patient = await patientDao.getPatient(patientId);
    final forms = await formDao.getFormsByPatientId(patientId);

    return {
      'patient': patient,
      'forms': forms,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Paciente'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPatientDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Nenhum dado encontrado'));
          } else {
            final patient = snapshot.data!['patient'] as PatientDetails;
            final forms = snapshot.data!['forms'] as List<FormUser>;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    patient,
                    SizedBox(height: 20),
                    if (forms.isNotEmpty) ...[
                      const Text('Formulários',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ...forms.map((form) {
                        return ListTile(
                          title: Text(form.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FormDetailScreen(formId: form.id),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ] else ...[
                      const Text('Nenhum formulário encontrado',
                          style: TextStyle(fontSize: 16)),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FormScreen(idPatient: patient.id),
                          ),
                        );
                      },
                      child: const Text('Criar formulario'),
                    ),
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
