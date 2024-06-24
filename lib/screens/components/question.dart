import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final String name;
  final int id;
  final String? nameTypeQuestion;
  final List<String>? answerOptions;
  final bool isSelectable;

  const Question(this.id, this.name, this.nameTypeQuestion, this.answerOptions,
      this.isSelectable, // Novo parâmetro booleano
      {Key? key})
      : super(key: key);

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  String?
      _selectedOption; // Variável de estado para armazenar a opção selecionada
  final TextEditingController _textController =
      TextEditingController(); // Controlador para o TextFormField

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
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Resposta',
                    ),
                  ),
                if (widget.answerOptions != null)
                  ...widget.answerOptions!.map((option) {
                    return RadioListTile(
                      value: option,
                      groupValue: _selectedOption,
                      onChanged: widget.isSelectable
                          ? (value) {
                              setState(() {
                                _selectedOption = value as String?;
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
