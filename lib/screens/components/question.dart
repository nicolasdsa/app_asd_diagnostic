import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final String name;
  final int id;
  final String? nameTypeQuestion;

  const Question(this.id, this.name, this.nameTypeQuestion, [Key? key])
      : super(key: key);

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.name),
        ),
      ),
    );
  }
}
