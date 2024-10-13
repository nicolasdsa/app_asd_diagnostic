import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:app_asd_diagnostic/screens/components/patient.dart';
import 'package:app_asd_diagnostic/screens/patients_create_screen.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({Key? key}) : super(key: key);

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final patientChangeNotifier = ValueNotifier(0);
  final _patientDao = PatientDao();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pacientes', showBackArrow: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar pacientes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: patientChangeNotifier,
              builder: (context, value, child) {
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _searchQuery.isEmpty
                      ? _patientDao.getAll()
                      : _patientDao.filterByName(_searchQuery),
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
                          return Patient(
                              patient['id'],
                              patient['name'],
                              patient['photo'],
                              patient['age'],
                              patient['gender'],
                              patientChangeNotifier);
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientCreateScreen(
                  patientChangeNotifier: patientChangeNotifier),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
