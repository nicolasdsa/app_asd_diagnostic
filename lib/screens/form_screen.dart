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
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Data'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _formDao.insertForm({
                      'name': _name,
                    }); // Replace with your method to add data to the SQLite table
                    widget.formChangeNotifier.value++;
                    Navigator.pop(context); // Go back to the previous screen
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
