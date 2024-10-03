import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CombinedLineChart extends StatefulWidget {
  final int idPatient;
  final Function(String?, DateTime?, DateTime?, bool) onExpansionChange;

  const CombinedLineChart(
      {super.key, required this.idPatient, required this.onExpansionChange});

  @override
  State<CombinedLineChart> createState() => _CombinedLineChartState();
}

class _CombinedLineChartState extends State<CombinedLineChart> {
  final JsonDataDao jsonDataDao = JsonDataDao();
  late Future<Map<String, List<List<dynamic>>>> futureJsonData;
  DateTime? startDate;
  DateTime? endDate;
  Map<String, bool> expandedGames = {};
  String? selectedGame;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(Duration(days: 30));
    endDate = DateTime.now();
    futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
        widget.idPatient, startDate!, endDate!);
  }

  void _pickStartDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null && (endDate == null || date.isBefore(endDate!))) {
      setState(() {
        startDate = date;
        futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
            widget.idPatient, startDate!, endDate!);

        widget.onExpansionChange(selectedGame, startDate, endDate, false);
      });
    }
  }

  void _pickEndDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null && (startDate == null || date.isAfter(startDate!))) {
      setState(() {
        endDate = date;
        futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(
            widget.idPatient, startDate!, endDate!);

        widget.onExpansionChange(selectedGame, startDate, endDate, false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                    "Start Date: ${DateFormat('yyyy-MM-dd').format(startDate!)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                    "End Date: ${DateFormat('yyyy-MM-dd').format(endDate!)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickEndDate,
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: futureJsonData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData ||
                (snapshot.data as Map<String, List<List<dynamic>>>).isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('Nenhum dado encontrado')),
              );
            } else {
              Map<String, List<List<dynamic>>> allJsonData =
                  snapshot.data as Map<String, List<List<dynamic>>>;

              return SingleChildScrollView(
                child: Column(
                  children: allJsonData.keys.map((game) {
                    bool isExpanded = expandedGames[game] ?? false;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            game,
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
                              expandedGames[game] = !isExpanded;
                              selectedGame = game;
                            });
                          },
                          onLongPress: () {
                            widget.onExpansionChange(
                                game, startDate, endDate, true);
                          },
                        ),
                        if (isExpanded)
                          ...allJsonData[game]!.map((chartData) {
                            String chartTitle = chartData[0];
                            List<FlSpot> spots =
                                List.generate(chartData[1].length, (index) {
                              var dataPoint = chartData[1][index];
                              return FlSpot(index.toDouble(),
                                  double.parse(dataPoint[0].toString()));
                            });

                            List<String> dates =
                                chartData[1].map<String>((dataPoint) {
                              var date = dataPoint[1];
                              return date != null
                                  ? DateFormat('dd/MM')
                                      .format(DateTime.parse(date))
                                  : '';
                            }).toList();

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    chartTitle,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
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
                                          color: Colors.blue,
                                          barWidth: 4,
                                          isStrokeCapRound: true,
                                          dotData: const FlDotData(show: true),
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        show: true,
                                        rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) =>
                                                bottomTitleWidgets(
                                                    value, meta, dates),
                                          ),
                                        ),
                                      ),
                                      minX: 0,
                                      minY: 0,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
          },
        ),
      ],
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
