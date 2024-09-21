import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final String name;
  final int id;
  final List<String>? answerOptions;
  final bool isSelectable;
  final ValueNotifier<String?> selectedOptionNotifier;
  final ValueNotifier<String?> selectedPositionNotifier;
  final TextEditingController textController;
  final List<String>? answerOptionIds;
  final Color backgroundColor;
  final String? initialAnswer;

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
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Text(widget.name,
                        style: Theme.of(context).textTheme.labelMedium),
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
                    print(option);
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
                                print(widget.selectedOptionNotifier.value);
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
