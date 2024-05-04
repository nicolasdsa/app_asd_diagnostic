import 'package:flutter/material.dart';

class Patient extends StatefulWidget {
  final String name;
  final int id;
  const Patient(this.id, this.name, [Key? key]) : super(key: key);

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/patient_details',
            arguments: {'id': widget.id});
      },
      child: Row(
        children: [
          const Icon(Icons.person),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.name)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => (),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => (),
          ),
        ],
      ),
    );
  }
}
