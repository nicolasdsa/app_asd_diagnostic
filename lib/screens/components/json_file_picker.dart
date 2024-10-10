import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class JsonFilePicker extends StatefulWidget {
  final Function(Map<String, dynamic>) onJsonSelected;

  const JsonFilePicker({Key? key, required this.onJsonSelected})
      : super(key: key);

  @override
  JsonFilePickerState createState() => JsonFilePickerState();
}

class JsonFilePickerState extends State<JsonFilePicker> {
  String? _selectedFileName;

  Future<void> _pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);
      String content = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(content);

      // Validar a estrutura do JSON
      if (_validateJsonStructure(jsonData)) {
        widget.onJsonSelected(jsonData);
        setState(() {
          _selectedFileName = result.files.single.name;
        });
      } else {
        _showErrorDialog('O arquivo JSON não está na estrutura esperada.');
      }
    }
  }

  bool _validateJsonStructure(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('dados')) {
      for (var item in jsonData['dados']) {
        if (!item.containsKey('json')) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickJsonFile,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.grey),
            ),
          ),
          child: const Text('Escolher Arquivo .json',
              style: TextStyle(color: Colors.black)),
        ),
        if (_selectedFileName != null)
          Text('Arquivo selecionado: $_selectedFileName',
              style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
