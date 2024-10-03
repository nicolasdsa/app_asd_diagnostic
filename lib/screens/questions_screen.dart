import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({Key? key}) : super(key: key);

  @override
  QuestionsScreenState createState() => QuestionsScreenState();
}

class QuestionsScreenState extends State<QuestionsScreen> {
  final QuestionDao _questionDao = QuestionDao();
  final ValueNotifier<List<Map<String, dynamic>>> _questionsNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    List<Map<String, dynamic>> questionsAll = await _questionDao.getAll();
    _questionsNotifier.value = questionsAll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Minhas questões'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _questionsNotifier,
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Question(
                        value[index]['id'],
                        value[index]['question'],
                        value[index]['answerOptions'],
                        false,
                        ValueNotifier(null),
                        TextEditingController(),
                        value[index]['answerOptionIds'],
                        ValueNotifier(null),
                        backgroundColor: Colors.white,
                        showIcons: true,
                        testNotifier: _questionsNotifier,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/createQuestion',
                    arguments: {"notifier": _questionsNotifier}),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  'Adicionar pergunta',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionsNotifier.dispose();
    super.dispose();
  }
}
