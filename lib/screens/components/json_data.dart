import 'package:flutter/material.dart';

class JsonData extends StatefulWidget {
  final String formattedData;
  final int id;

  const JsonData(this.id, this.formattedData, [Key? key]) : super(key: key);

  @override
  State<JsonData> createState() => _JsonDataState();
}

class _JsonDataState extends State<JsonData> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(widget.formattedData),
      ),
    );
  }
}
