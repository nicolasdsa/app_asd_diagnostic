import 'package:app_asd_diagnostic/db/answer_options_dao.dart';
import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/question.dart';
import 'package:app_asd_diagnostic/screens/questions_create_screen.dart';
import 'package:flutter/material.dart';

class Questions extends StatefulWidget {
  final List<dynamic> analiseInfoElements;
  final Function(String, dynamic) addElementToAnaliseInfo;

  const Questions({
    super.key,
    required this.analiseInfoElements,
    required this.addElementToAnaliseInfo,
  });

  @override
  QuestionsState createState() => QuestionsState();
}

class QuestionsState extends State<Questions> {
  late ValueNotifier<List<Map<String, dynamic>>> questionChangeNotifier;
  late ValueNotifier<int> questionAddNotifier;

  @override
  void initState() {
    super.initState();
    questionChangeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    questionAddNotifier = ValueNotifier(0);
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await QuestionDao().getAll();
    questionChangeNotifier.value = questions;
  }

  @override
  void dispose() {
    questionChangeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: questionChangeNotifier,
          builder: (context, items, _) {
            return Column(
              children: items.map((item) {
                ValueNotifier<bool> isIncludedInAnalysis = ValueNotifier(
                  widget.analiseInfoElements.any((element) =>
                      element[1] == item['id'] && element[0] == 'questions'),
                );

                return FutureBuilder<String>(
                  future:
                      TypeQuestionDao().getTypeQuestionName(item['id_type']),
                  builder: (context, typeSnapshot) {
                    if (typeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (typeSnapshot.hasError) {
                      return Text('Error: ${typeSnapshot.error}');
                    } else {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: AnswerOptionsDao()
                            .getOptionsForQuestion(item['id']),
                        builder: (context, optionsSnapshot) {
                          List<String>? answerOptions;
                          List<String>? answerOptionIds;

                          if (optionsSnapshot.hasData) {
                            answerOptions = optionsSnapshot.data!
                                .map(
                                    (option) => option['option_text'] as String)
                                .toList();

                            answerOptionIds = optionsSnapshot.data!
                                .map((option) => option['id'].toString())
                                .toList();
                          }

                          return ValueListenableBuilder<bool>(
                            valueListenable: isIncludedInAnalysis,
                            builder: (context, isIncluded, _) {
                              return GestureDetector(
                                onTap: () {
                                  widget.addElementToAnaliseInfo(
                                      'questions', item['id']);
                                  isIncludedInAnalysis.value =
                                      !isIncludedInAnalysis.value;
                                },
                                child: Question(
                                  item['id'],
                                  item['question'],
                                  answerOptions,
                                  false,
                                  ValueNotifier<String?>(null),
                                  TextEditingController(),
                                  answerOptionIds,
                                  ValueNotifier<String?>(null),
                                  backgroundColor:
                                      isIncluded ? Colors.grey : Colors.white,
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionCreateScreen(),
                ),
              );
            },
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
    );
  }
}
