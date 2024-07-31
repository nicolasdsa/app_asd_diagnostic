import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData extends StatefulWidget {
  final int idPatient;
  final DateTime startDate;
  final DateTime endDate;
  final String game;

  const ChartData({
    super.key,
    required this.idPatient,
    required this.startDate,
    required this.endDate,
    required this.game,
  });

  @override
  State<ChartData> createState() => _ChartDataState();
}

class _ChartDataState extends State<ChartData> {
  final JsonDataDao jsonDataDao = JsonDataDao();
  late Future<List<List<dynamic>>> futureJsonData;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    futureJsonData = jsonDataDao.getAllJsonDataByGameAndDate(
      widget.game,
      widget.idPatient,
      widget.startDate,
      widget.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureJsonData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          List<List<dynamic>> allJsonData =
              snapshot.data as List<List<dynamic>>;
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

            return Column(
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
            );
          }).toList();

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
                if (isExpanded) ...chartWidgets
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
