import 'package:flutter/material.dart';

class PatientDetails extends StatelessWidget {
  final String name;
  final int age;
  final int id;
  final String gender;

  const PatientDetails({
    Key? key,
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nome: $name',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('Idade: $age', style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        Text('Gênero: $gender', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
