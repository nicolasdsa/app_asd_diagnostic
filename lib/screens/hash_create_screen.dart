import 'dart:convert';

import 'package:app_asd_diagnostic/db/game_dao.dart';
import 'package:app_asd_diagnostic/db/hash_access_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';

class HashCreateScreen extends StatefulWidget {
  final List<List<dynamic>> elements;
  final int idPatient;

  const HashCreateScreen({
    Key? key,
    required this.elements,
    required this.idPatient,
  }) : super(key: key);

  @override
  HashCreateScreenState createState() => HashCreateScreenState();
}

class HashCreateScreenState extends State<HashCreateScreen> {
  // Armazena as seleções para cada jogo
  final Map<int, Map<String, dynamic>> _selectedConfigs = {};
  final Map<int, Map<String, TextEditingController>> _textControllers =
      {}; // Novo mapa para armazenar controladores

  @override
  void dispose() {
    // Certifique-se de liberar os controladores quando não forem mais necessários
    _textControllers.forEach((gameId, controllers) {
      controllers.forEach((key, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleção de Jogos')),
      body: ListView.builder(
        itemCount: widget.elements.length,
        itemBuilder: (context, index) {
          final gameId = widget.elements[index][1]; // ID do jogo

          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchGameConfig(gameId), // Carrega o jogo pelo ID
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final game = snapshot.data!;
              return _buildGameConfig(game, gameId);
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _isFormValid() ? _createSection : null,
          child: const Text('Criar seção'),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchGameConfig(int gameId) async {
    final result = await GameDao().getOne(gameId.toString());
    return result;
  }

  Widget _buildGameConfig(Map<String, dynamic> game, int gameId) {
    final config = jsonDecode(game['config']);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game['name'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8.0),
            ...config.keys.map((key) {
              if (config[key] is List) {
                List<String> options = List<String>.from(config[key]);
                return _buildRadioListTile(key, options, gameId);
              }
              if (config[key] is int) {
                return _buildTextField(key, config[key], gameId);
              }
              return Container();
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioListTile(String key, List<String> options, int gameId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedConfigs[gameId]?[key],
            onChanged: (value) {
              setState(() {
                _selectedConfigs[gameId] = {
                  ...?_selectedConfigs[gameId],
                  key: value,
                };
              });
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextField(String key, int initialValue, int gameId) {
    // Se o controlador para o jogo e a chave ainda não existe, cria um novo
    _textControllers[gameId] ??= {};
    _textControllers[gameId]![key] ??= TextEditingController(
      text:
          _selectedConfigs[gameId]?[key]?.toString() ?? initialValue.toString(),
    );

    final controller = _textControllers[gameId]![key]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _selectedConfigs[gameId] = {
                ...?_selectedConfigs[gameId],
                key: int.tryParse(value) ?? initialValue,
              };
            });
          },
        ),
      ],
    );
  }

  bool _isFormValid() {
    for (final gameConfig in _selectedConfigs.values) {
      for (final value in gameConfig.values) {
        if (value == null || value.toString().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _createSection() async {
    final hashAccessDao = HashAccessDao();

    final List<String> sectionData = [];
    _selectedConfigs.forEach((gameId, config) {
      config['Id'] = gameId; // Add the 'Id' key with gameId as the value
      sectionData.add(jsonEncode(config)); // Use jsonEncode instead of toString
    });

    final String result = '${widget.idPatient}-${sectionData.join(",")}';
    final bytes = utf8.encode(result);
    final hash = sha256.convert(bytes).toString();

    print('Hash gerado: $hash');

    // Salva no banco de dados
    final hashAccess = {
      'id_patient': widget.idPatient,
      'accessHash': hash,
      'gameLinks': result,
    };
    await hashAccessDao.insert(hashAccess);
    await Clipboard.setData(ClipboardData(text: hash));

    print('Seção criada: $result');

    // Exibe o modal com o hash gerado
    showDialog(
      context: context,
      barrierDismissible: false, // Impede o fechamento ao clicar fora do modal
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hash Gerado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A sessão foi criada com sucesso. O hash gerado é:'),
              const SizedBox(height: 10),
              Text(
                hash,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                  'Você será redirecionado para a página do paciente ao fechar.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal

                // Redireciona para a página de pacientes e remove a tela atual da pilha
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/patient',
                  arguments: {'patientId': widget.idPatient.toString()},
                  (Route<dynamic> route) =>
                      false, // Remove todas as rotas anteriores
                );
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
