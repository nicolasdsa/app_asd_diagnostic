import 'dart:convert';
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:app_asd_diagnostic/db/user.dart';
import 'package:app_asd_diagnostic/screens/components/game.dart';
import 'package:app_asd_diagnostic/screens/login_and_hash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HashDataScreen extends StatefulWidget {
  final String hash;

  const HashDataScreen({super.key, required this.hash});

  @override
  State<HashDataScreen> createState() => _HashDataScreenState();
}

class _HashDataScreenState extends State<HashDataScreen> {
  List<Map<String, dynamic>> gameDetails = [];
  String idPatient = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHash', false);
    await prefs.setString('hash', '');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginAndHashScreen()),
      (route) => false, // Remove todas as rotas anteriores
    );
  }

  Future<void> _showLogoutModal() async {
    final formKey = GlobalKey<FormState>();
    String username = '';
    String password = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Digite as informações para ter acesso ao menu'),
          content: Form(
            key: formKey, // Define a chave do formulário para validação
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Usuário'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o usuário';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    username = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Se o formulário for válido, salva os campos
                  formKey.currentState!.save();
                  if (await _validateCredentials(username, password)) {
                    Navigator.of(context).pop();
                    _showOptionsModal(); // Mostra as opções após autenticação
                  } else {
                    // Exibe uma mensagem de erro caso as credenciais estejam incorretas
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Credenciais inválidas')),
                    );
                  }
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validateCredentials(String username, String password) async {
    final dao = UserDao();

    final success = await dao.loginHash(username, password);

    return success;
  }

  Future<void> _showOptionsModal() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opções'),
          content: const Text('Escolha uma opção:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(); // Chama o método de logout
              },
              child: const Text('Sair'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportToJson(); // Chama o método de exportação
              },
              child: const Text('Exportar dados para JSON'),
            ),
          ],
        );
      },
    );
  }

  void _exportToJson() async {
    try {
      HashAccessDao hashAccessDao = HashAccessDao();
      JsonDataDao jsonDataDao = JsonDataDao();
      GameDao gameDao = GameDao();
      List<String> gamesNames = [];

      final hashData = await hashAccessDao.getOne(widget.hash);
      final gameLinks = hashData!['gameLinks'];
      idPatient = gameLinks.split('-')[0];
      final games = gameLinks.split('-')[1].split(', ');

      for (var game in games) {
        final properties = jsonDecode(game);
        final gameData = await gameDao.getOne(properties["Id"].toString());
        gamesNames.add(
            '${gameData['name']} - Dificuldade: ${properties['Dificuldade']} - Modo: ${properties['Modos']}');
      }

      final result = await jsonDataDao.exportJson(
          idPatient, gamesNames, hashData['created_at']);

      // Lógica para exportar dados para JSON
      final data = {'dados': result};

      final jsonData = jsonEncode(data);

      final Directory? downloadsDirectory = await getExternalStorageDirectory();

      final Map<String, dynamic> patientData =
          await PatientDao().getPatientById(int.parse(idPatient));
      final String patientName = patientData['name'];

      final String timestamp =
          DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());

      final String path =
          '${downloadsDirectory!.path}/$patientName-$timestamp.json';

      // Salva o JSON em um arquivo temporário
      final file = File(path);
      await file.writeAsString(jsonData);

      // Usa o flutter_file_dialog para abrir a caixa de diálogo de salvamento
      final params = SaveFileDialogParams(
          sourceFilePath: path, fileName: '$patientName-$timestamp.json');
      await FlutterFileDialog.saveFile(params: params);

      // Exibe o SnackBar informando que o arquivo foi salvo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo JSON exportado com sucesso!')),
      );
    } catch (e) {
      // Exibe um erro no SnackBar caso algo dê errado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao exportar o arquivo JSON')),
      );
    }
  }

  Future<void> _loadGameDetails() async {
    final hashAccessDao = HashAccessDao();
    final gameDao = GameDao();

    final hashData = await hashAccessDao.getOne(widget.hash);
    final gameLinks = hashData!['gameLinks'];
    idPatient = gameLinks.split('-')[0];
    final games = gameLinks.split('-')[1].split(', ');

    for (var game in games) {
      final gameDecode = jsonDecode(game);
      final gameData = await gameDao.getOne(gameDecode["Id"].toString());
      gameDetails.add({
        'game': gameData,
        'properties': gameDecode,
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dados da Hash'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados da Hash'),
        automaticallyImplyLeading: false, // Remove o botão de voltar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                _showLogoutModal, // Chama o método de logout ao pressionar
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gameDetails.length,
        itemBuilder: (context, index) {
          final game = gameDetails[index]['game'];
          final properties = gameDetails[index]['properties'];

          return ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                game['link'],
                arguments: {
                  'idPatient': idPatient,
                  'properties': properties,
                  'id': game['id'],
                },
              );
            },
            child: GameComponent(
              game['name'],
              game['link'],
              id: game['id'],
              path: game['path'],
              shortDescription: game['short_description'],
            ),
          );
        },
      ),
    );
  }
}
