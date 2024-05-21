import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final String name;
  final int id;
  final String? nameTypeQuestion;
  final List<String>? answerOptions;

  const Question(this.id, this.name, this.nameTypeQuestion, this.answerOptions,
      [Key? key])
      : super(key: key);

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {},
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    child: Text(widget.name),
                  ),
                  if (widget.answerOptions != null)
                    ...widget.answerOptions!.map((option) {
                      return RadioListTile(
                        value: option,
                        groupValue: null,
                        onChanged: null,
                        title: Text(option),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
