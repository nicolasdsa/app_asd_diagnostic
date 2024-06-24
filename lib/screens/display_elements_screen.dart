import 'package:app_asd_diagnostic/db/json_data_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:flutter/material.dart';

class DisplayElementsScreen extends StatelessWidget {
  final List<List<dynamic>> elements;

  DisplayElementsScreen({required this.elements});

  Future<List<Widget>> componentsPage(List<List<dynamic>> elements) async {
    List<Widget> _avaliarComportamentoElements = [];

    for (List<dynamic> element in elements) {
      if (element.isNotEmpty && element[0] == 'json_data') {
        final jsonDataDao = JsonDataDao();
        final jsonData = await jsonDataDao.getOne(element[1]);
        _avaliarComportamentoElements.add(jsonData);
      } else if (element.isNotEmpty && element[0] == 'questions') {
        final questionDao = QuestionDao();
        final question = await questionDao.getOne(element[1]);
        _avaliarComportamentoElements.add(question);
      }
    }
    return _avaliarComportamentoElements;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Elements'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Widget>>(
          future: componentsPage(elements),
          builder:
              (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum dado adicionado'));
            } else {
              return Column(
                children: snapshot.data!,
              );
            }
          },
        ),
      ),
    );
  }
}
