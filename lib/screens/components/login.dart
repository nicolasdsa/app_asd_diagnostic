import 'package:app_asd_diagnostic/db/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginComponent extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final UserDao _dao = UserDao();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginComponent({super.key});

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState?.validate() == true) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final success = await _dao.login(email, password);
      if (success) {
        final user = await _dao.getOne(_emailController.text);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('inf', user['id'].toString());
        Navigator.pushNamedAndRemoveUntil(
            context, '/initial', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha ou email inválidos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
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
              if (value!.isEmpty) {
                return 'Escreva o email';
              }
              return null;
            },
          ),
          const SizedBox(height: 22.0),
          Text(
            'Senha',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12.0),
          // Campo de Idade
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Escreva a senha';
              }
              return null;
            },
          ),

          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => _login(context),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.key,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
