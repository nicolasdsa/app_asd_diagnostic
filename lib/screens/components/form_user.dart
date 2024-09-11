import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormUser extends StatefulWidget {
  final String name;
  final int id;
  final String createdAt;

  const FormUser({
    Key? key,
    required this.id,
    required this.name,
    required this.createdAt,
  }) : super(key: key);

  @override
  State<FormUser> createState() => _FormState();
}

class _FormState extends State<FormUser> {
  @override
  Widget build(BuildContext context) {
    // Formata a data de criação
    final createdAtDate = DateTime.parse(widget.createdAt);
    final formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/form',
            arguments: {'formId': widget.id.toString()});
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment), // Ícone de formulário
                    const SizedBox(width: 8),
                    Text(widget.name),
                  ],
                ),
                Text(formattedDate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
