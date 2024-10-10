import 'package:app_asd_diagnostic/db/user.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final UserDao _dao = UserDao();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _crmController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Registro do Profissional'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text('Nome Completo',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, coloque seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Usuário', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Email', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor coloque seu email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Senha', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor coloque sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Confirmar Senha',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirme sua senha';
                    } else if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Número de Registro (CRM)',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _crmController,
                  decoration: const InputDecoration(
                    labelText: 'CRM',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor coloque seu CRM';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                Text('Instituição',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Instituição',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor coloque sua instituição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      final name = _nameController.text;
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      final username = _usernameController.text;
                      final crm = _crmController.text;
                      final hospital = _hospitalController.text;

                      try {
                        await _dao.insert(
                            name, email, username, password, hospital, crm);
                        Navigator.pushReplacementNamed(context, '/');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registro criado com sucesso!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao criar registro: $e'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "Registrar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
