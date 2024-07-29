import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportButton extends StatelessWidget {
  final int patientId;
  final String game;

  ExportButton({required this.patientId, required this.game});

  Future<void> _exportToExcel() async {
    final JsonDataDao _jsonDataDao = JsonDataDao();
    List<Map<String, dynamic>> filteredData = await _jsonDataDao
        .getRowsByPatientIdAndGame(patientId.toString(), game);

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
          .value = TextCellValue('created_at');

      // Add data
      for (int i = 0; i < filteredData.length; i++) {
        Map<String, dynamic> jsonData = jsonDecode(filteredData[i]['json']);
        for (int j = 0; j < keys.length; j++) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
              .value = TextCellValue(jsonData[keys[j]].toString());
        }

        print(filteredData[i]['created_at']);
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: keys.length, rowIndex: i + 1))
            .value = TextCellValue(filteredData[i]['created_at'].toString());
      }

      final Directory? downloadsDirectory = await getExternalStorageDirectory();
      final String path = '${downloadsDirectory!.path}/patient_data_test.xlsx';
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      print('Exported to $path');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _exportToExcel,
      child: Text('Export to Excel'),
    );
  }
}
