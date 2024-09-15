import 'dart:convert';

import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData extends StatefulWidget {
  final int idPatient;
  final DateTime startDate;
  final DateTime endDate;
  final String game;
  final bool initiallyExpanded;
  final Function(List<GlobalKey>)? onKeysGenerated;
  final Color? selectedColor; // Novo parâmetro

  const ChartData({
    super.key,
    required this.idPatient,
    required this.startDate,
    required this.endDate,
    required this.game,
    this.onKeysGenerated,
    this.initiallyExpanded = false,
    this.selectedColor, // Inicializando o parâmetro
  });

  @override
  State<ChartData> createState() => _ChartDataState();
}

class _ChartDataState extends State<ChartData> {
  List<GlobalKey> _repaintBoundaryKeys = [];
  final JsonDataDao jsonDataDao = JsonDataDao();
  late Future<List<List<dynamic>>> futureJsonData;
  late bool isExpanded;

  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;

    futureData = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    // Obtém os dados do jogo e do período
    List<List<dynamic>> jsonData =
        await jsonDataDao.getAllJsonDataByGameAndDate(
      widget.game,
      widget.idPatient,
      widget.startDate,
      widget.endDate,
    );

    // Obtém os dados de json_flag e json_flag_description
    List<Map<String, dynamic>> rows =
        await jsonDataDao.getRowsByPatientIdAndGame(
      widget.idPatient.toString(),
      widget.game,
    );

    Map<String, dynamic> flagCounts = {};
    Map<String, dynamic> flagDescriptions = {};

    for (var row in rows) {
      Map<String, dynamic> jsonFlag = jsonDecode(row['json_flag']);
      Map<String, dynamic> jsonFlagDescription =
          jsonDecode(row['json_flag_description']);

      jsonFlag.forEach((key, value) {
        if (!flagCounts.containsKey(key)) {
          flagCounts[key] = {};
        }
        flagCounts[key][value] = (flagCounts[key][value] ?? 0) + 1;
      });

      flagDescriptions.addAll(jsonFlagDescription);
    }

    return {
      "jsonData": jsonData,
      "flagCounts": flagCounts,
      "flagDescriptions": flagDescriptions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          Map<String, dynamic> data = snapshot.data!;
          List<List<dynamic>> allJsonData = data["jsonData"];
          Map<String, dynamic> flagCounts = data["flagCounts"];
          Map<String, dynamic> flagDescriptions = data["flagDescriptions"];

          final tempKeys = <GlobalKey>[];

          List<Widget> chartWidgets = allJsonData.map((chartData) {
            String chartTitle = chartData[0];
            List<FlSpot> spots = List.generate(chartData[1].length, (index) {
              var dataPoint = chartData[1][index];
              return FlSpot(
                  index.toDouble(), double.parse(dataPoint[0].toString()));
            });

            List<String> dates = chartData[1].map<String>((dataPoint) {
              var date = dataPoint[1];
              return date != null
                  ? DateFormat('dd/MM').format(DateTime.parse(date))
                  : '';
            }).toList();

            GlobalKey repaintBoundaryKey = GlobalKey();
            tempKeys.add(repaintBoundaryKey);

            return RepaintBoundary(
              key: repaintBoundaryKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      chartTitle,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: widget.selectedColor ??
                                Colors.blue, // Usando a cor customizável
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget: (value, meta) =>
                                  bottomTitleWidgets(value, meta, dates),
                            ),
                          ),
                        ),
                        minX: 0,
                        minY: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList();

          if (widget.onKeysGenerated != null) {
            widget.onKeysGenerated!(tempKeys);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                    title: Text(
                      widget.game,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    }),
                if (isExpanded) ...[
                  ...chartWidgets,
                  // Adicione o novo widget aqui
                  Column(
                      children: flagCounts.entries.map((entry) {
                    String flagKey = entry.key;
                    Map<int, int> counts = (entry.value as Map).map(
                      (key, value) => MapEntry<int, int>(
                          int.parse(key.toString()),
                          int.parse(value.toString())),
                    );
                    int total = counts.values.reduce((a, b) => a + b);
                    int maxValue = counts.entries
                        .reduce((a, b) => a.value > b.value ? a : b)
                        .key;
                    double percentage = (counts[maxValue]! / total) * 100;
                    String description = flagDescriptions['$flagKey-$maxValue'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '$flagKey: ${percentage.toStringAsFixed(2)}% $description',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList()),
                ],
              ],
            ),
          );
        }
      },
    );
  }
}

Widget bottomTitleWidgets(double value, TitleMeta meta, List<String> dates) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  if (value.toInt() >= 0 && value.toInt() < dates.length) {
    String text = dates[value.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(text, style: style),
    );
  } else {
    return Container();
  }
}
