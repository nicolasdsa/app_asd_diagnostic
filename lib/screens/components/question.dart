import 'package:app_asd_diagnostic/db/question_dao.dart';
import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final String name;
  final int id;
  final List<String>? answerOptions;
  final bool isSelectable;
  final ValueNotifier<String?> selectedOptionNotifier;
  final ValueNotifier<String?> selectedPositionNotifier;
  final ValueNotifier<List<Map<String, dynamic>>>? testNotifier;
  final TextEditingController textController;
  final List<String>? answerOptionIds;
  final Color backgroundColor;
  final String? initialAnswer;
  final bool? showIcons;

  const Question(
      this.id,
      this.name,
      this.answerOptions,
      this.isSelectable,
      this.selectedOptionNotifier,
      this.textController,
      this.answerOptionIds,
      this.selectedPositionNotifier,
      {this.backgroundColor = Colors.white,
      this.initialAnswer,
      this.showIcons,
      this.testNotifier,
      Key? key})
      : super(key: key);

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  void initState() {
    super.initState();
    widget.textController.text = widget.initialAnswer ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Use Flexible para garantir que o texto ocupe o espaço necessário
                      Flexible(
                        child: Text(
                          widget.name,
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow
                              .ellipsis, // Adiciona reticências para textos longos
                        ),
                      ),
                      if (widget.showIcons == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final questionDao = QuestionDao();
                                bool isUse = await questionDao
                                    .checkQuestionIsInForm(widget.id);
                                if (isUse) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Essa questão não pode ser editada pois já foi adicionada em um formulário')),
                                  );
                                  return;
                                }
                                Navigator.pushNamed(context, '/createQuestion',
                                    arguments: {
                                      "idQuestion": widget.id,
                                      "notifier": widget.testNotifier
                                    });
                              },
                            ),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final questionDao = QuestionDao();
                                  bool success = await questionDao
                                      .deleteQuestionById(widget.id);
                                  if (success) {
                                    var questions = widget.testNotifier!.value;
                                    questions.removeWhere(
                                        (q) => q['id'] == widget.id);
                                    widget.testNotifier!.value = [...questions];

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Questão deletada com sucesso')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Essa questão não pode ser deletada pois já foi adicionada em um formulário')),
                                    );
                                  }
                                }),
                          ],
                        ),
                    ],
                  ),
                ),
                if (widget.isSelectable && widget.answerOptions == null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: widget.textController,
                      decoration: const InputDecoration(
                        labelText: 'Resposta',
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                if (widget.answerOptions != null)
                  ...widget.answerOptions!.map((option) {
                    return RadioListTile(
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.only(left: 6),
                      value: option,
                      groupValue: widget.selectedPositionNotifier.value,
                      onChanged: widget.isSelectable
                          ? (value) {
                              setState(() {
                                final position = widget.answerOptions!
                                    .indexOf(value as String);

                                widget.selectedPositionNotifier.value =
                                    value as String?;

                                widget.selectedOptionNotifier.value =
                                    widget.answerOptionIds?[position];
                              });
                            }
                          : null, // Desabilitar seleção se isSelectable for falso
                      title: Text(option,
                          style: Theme.of(context).textTheme.labelMedium),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
