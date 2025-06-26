import 'package:app_asd_diagnostic/screens/components/card_option.dart';
import 'package:app_asd_diagnostic/screens/components/login.dart';
import 'package:flutter/material.dart';
import 'components/access_hash.dart';

class LoginAndHashScreen extends StatefulWidget {
  const LoginAndHashScreen({super.key});

  @override
  State<LoginAndHashScreen> createState() => _LoginAndHashScreenState();
}

class _LoginAndHashScreenState extends State<LoginAndHashScreen> {
  final ValueNotifier<String?> _nameNotifier = ValueNotifier<String?>('Login');

  void _handleCardOptionTap(String name) {
    _nameNotifier.value = name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/screens/logo.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16.0),
                Text(
                  "Bem vindo de volta",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16.0),
                Container(
                  color: Colors.grey[200],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                  child: Row(
                    children: [
                      CardOption(
                        'Login',
                        Icons.login,
                        onTap: (name) => _handleCardOptionTap(name),
                        nameNotifier: _nameNotifier,
                      ),
                      const SizedBox(width: 8),
                      CardOption(
                        'Acesso por Hash',
                        Icons.tag,
                        onTap: (name) => _handleCardOptionTap(name),
                        nameNotifier: _nameNotifier,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String?>(
                  valueListenable: _nameNotifier,
                  builder: (context, name, _) {
                    if (name == 'Login') {
                      return LoginComponent(); // Mostrar componente de login
                    } else if (name == 'Acesso por Hash') {
                      return const AccessHashComponent(); // Mostrar componente de hash
                    } else {
                      return const SizedBox
                          .shrink(); // Nenhum componente selecionado
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Ou continue com",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
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
                            Icons.person_add,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            "Registrar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
