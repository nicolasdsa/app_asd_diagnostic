import 'dart:io';

import 'package:app_asd_diagnostic/screens/patients_create_screen.dart';
import 'package:flutter/material.dart';

class Patient extends StatefulWidget {
  final String name;
  final int id;
  final String url;
  final int age;
  final String gender;
  final ValueNotifier<int> patientChangeNotifier;

  const Patient(this.id, this.name, this.url, this.age, this.gender,
      this.patientChangeNotifier,
      [Key? key])
      : super(key: key);

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/patient',
            arguments: {'patientId': widget.id.toString()});
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey, // Cor da borda
              width: 1.0, // Largura da borda
            ),
          ),
        ),
        padding: const EdgeInsets.all(8.0), // Adiciona um pouco de padding
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: widget.url.isNotEmpty
                  ? FileImage(File(widget.url)) as ImageProvider
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name.length > 20
                        ? '${widget.name.substring(0, 20)}...'
                        : widget.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('Idade: ${widget.age}',
                      style: const TextStyle(fontSize: 12)),
                  Text('Gênero: ${widget.gender}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientCreateScreen(
                      patientChangeNotifier: widget.patientChangeNotifier,
                      patientId: widget.id,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => (),
            ),
          ],
        ),
      ),
    );
  }
}
