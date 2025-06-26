import 'dart:convert';
import 'package:app_asd_diagnostic/db/patient_dao.dart';
import 'package:excel/excel.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart'; // Adicione este import

class ExportButton extends StatelessWidget {
  final int? patientId;
  final String? game;

  const ExportButton({super.key, required this.patientId, required this.game});

  Future<void> _exportToExcel(BuildContext context) async {
    final JsonDataDao jsonDataDao = JsonDataDao();
    List<Map<String, dynamic>> filteredData = await jsonDataDao
        .getRowsByPatientIdAndGame(patientId.toString(), game!);

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    if (filteredData.isNotEmpty) {
      Map<String, dynamic> firstJson = jsonDecode(filteredData.first['json']);
      List<String> keys = firstJson.keys.toList();

      // Add headers
      for (int i = 0; i < keys.length; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(keys[i]);
      }
      sheetObject
          .cell(
              CellIndex.indexByColumnRow(columnIndex: keys.length, rowIndex: 0))
          .value = const TextCellValue('created_at');

      for (int i = 0; i < filteredData.length; i++) {
        Map<String, dynamic> jsonData = jsonDecode(filteredData[i]['json']);
        for (int j = 0; j < keys.length; j++) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
              .value = TextCellValue(jsonData[keys[j]].toString());
        }

        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: keys.length, rowIndex: i + 1))
            .value = TextCellValue(filteredData[i]['created_at'].toString());
      }

      final Map<String, dynamic> patientData =
          await PatientDao().getPatientById(patientId!);
      final String patientName = patientData['name'];

      final String timestamp =
          DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());

      // Salva o arquivo Excel em um arquivo temporário
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/$patientName-$timestamp.xlsx';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(excel.encode()!);

      // Usa o FlutterFileDialog para permitir que o usuário escolha o local
      final params = SaveFileDialogParams(
        sourceFilePath: tempPath,
        fileName: '$patientName-$timestamp.xlsx',
      );
      await FlutterFileDialog.saveFile(params: params);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo Excel exportado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: () => _exportToExcel(context),
      child: const SizedBox(
        width: double.infinity,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_download,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 8.0),
              Text(
                "Exportar para XLSS",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
