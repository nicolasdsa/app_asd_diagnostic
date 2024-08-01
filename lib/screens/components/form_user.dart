import 'package:flutter/material.dart';

class FormUser extends StatefulWidget {
  final String name;
  final int id;
  const FormUser(this.id, this.name, [Key? key]) : super(key: key);

  @override
  State<FormUser> createState() => _FormState();
}

class _FormState extends State<FormUser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [Text(widget.name)],
      ),
    );
  }
}
