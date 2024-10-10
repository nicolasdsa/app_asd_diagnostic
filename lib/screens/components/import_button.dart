import 'dart:convert';

import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:flutter/material.dart';

class ImportButton extends StatelessWidget {
  final int? patientId;
  final Map<String, dynamic>? jsonData;

  const ImportButton(
      {super.key, required this.patientId, required this.jsonData});

  Future<void> _importJson(BuildContext context) async {
    final JsonDataDao jsonDataDao = JsonDataDao();

    try {
      for (var item in jsonData!['dados']) {
        String game = item['game'];
        String createdAt = item['created_at'];

        // Verificar se já existe um registro com o mesmo id_patient, game e created_at
        bool exists = await jsonDataDao.exists(patientId!, game, createdAt);
        if (!exists) {
          // Adicionar o id_patient ao JSON
          item['id_patient'] = patientId;
          item['json'] = jsonEncode(item['json']);
          item['json_flag'] = jsonEncode(item['json_flag']);
          item['json_flag_description'] =
              jsonEncode(item['json_flag_description']);

          // Inserir o novo registro
          await jsonDataDao.insert(item);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Importação realizada com sucesso!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao importar os dados.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _importJson(context),
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
                Icons.upload_file,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 8.0),
              Text(
                "Importar",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
