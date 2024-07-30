import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CombinedLineChart extends StatefulWidget {
  final int idPatient;

  const CombinedLineChart({super.key, required this.idPatient});

  @override
  State<CombinedLineChart> createState() => _CombinedLineChartState();
}

class _CombinedLineChartState extends State<CombinedLineChart> {
  final JsonDataDao jsonDataDao = JsonDataDao();
  late Future<Map<String, List<List<dynamic>>>> futureJsonData;
  Map<String, bool> expandedGames = {};

  @override
  void initState() {
    super.initState();
    futureJsonData = jsonDataDao.getAllJsonDataGroupedByGame(widget.idPatient);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureJsonData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            (snapshot.data as Map<String, List<List<dynamic>>>).isEmpty) {
          return const Center(child: Text('No data available'));
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
                        });
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
                              ? DateFormat('dd/MM').format(DateTime.parse(date))
                              : '';
                        }).toList();

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                chartTitle,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
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
