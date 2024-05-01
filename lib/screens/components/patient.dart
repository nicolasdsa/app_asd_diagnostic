import 'package:flutter/material.dart';

class Patient extends StatefulWidget {
  final String name;
  final String id;

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
          Icon(Icons.person),
          SizedBox(width: 8),
          Expanded(child: Text(widget.name)),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => (),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => (),
          ),
        ],
      ),
    );
  }
}
