import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  FormScreen({required this.formChangeNotifier});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formDao = FormDao();

  String _name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  const SizedBox(height: 16.0),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
