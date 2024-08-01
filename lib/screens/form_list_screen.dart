import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/screens/form_detail_screen.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';

class FormListScreen extends StatefulWidget {
  @override
  _FormListScreenState createState() => _FormListScreenState();
}

class _FormListScreenState extends State<FormListScreen> {
  late Future<List<FormUser>> _forms;

  @override
  void initState() {
    super.initState();
    _forms = FormDao().getAllForms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulários'),
      ),
      body: FutureBuilder<List<FormUser>>(
        future: _forms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum formulário encontrado'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final form = snapshot.data![index];
                return ListTile(
                  title: Text(form.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormDetailScreen(formId: form.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
