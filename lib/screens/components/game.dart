import 'package:flutter/material.dart';

class GameComponent extends StatefulWidget {
  final String name;
  final String link; // Adicione esta linha

  const GameComponent(this.name, this.link, [Key? key])
      : super(key: key); // Modifique esta linha

  @override
  State<GameComponent> createState() => _GameState();
}

class _GameState extends State<GameComponent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(child: Text(widget.name)),
        const SizedBox(width: 8),
      ],
    );
  }
}