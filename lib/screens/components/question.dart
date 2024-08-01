import 'package:app_asd_diagnostic/screens/test_screen.dart';
import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final String name;
  final int id;
  final String? nameTypeQuestion;
  final List<String>? answerOptions;
  final bool isSelectable;
  final ValueNotifier<String?> selectedOptionNotifier;
  final ValueNotifier<String?> selectedPositionNotifier; // Novo ValueNotifier
  final TextEditingController textController; // Novo TextEditingController
  final List<String>? answerOptionIds;

  const Question(
      this.id,
      this.name,
      this.nameTypeQuestion,
      this.answerOptions,
      this.isSelectable, // Novo parâmetro booleano
      this.selectedOptionNotifier, // Novo ValueNotifier
      this.textController,
      this.answerOptionIds, // Novo TextEditingController
      this.selectedPositionNotifier, // Novo TextEditingController
      {Key? key})
      : super(key: key);

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  child: Text(widget.name),
                ),
                if (widget.isSelectable && widget.answerOptions == null)
                  TextFormField(
                    controller: widget.textController,
                    decoration: const InputDecoration(
                      labelText: 'Resposta',
                    ),
                  ),
                if (widget.answerOptions != null)
                  ...widget.answerOptions!.map((option) {
                    return RadioListTile(
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
                      title: Text(option),
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
