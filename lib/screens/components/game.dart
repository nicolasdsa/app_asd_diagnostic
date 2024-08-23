import 'package:flutter/material.dart';

class GameComponent extends StatefulWidget {
  final String name;
  final String link;
  final int id; // Add this line
  final Color backgroundColor; // Novo parâmetro

  const GameComponent(this.name, this.link,
      {required this.id, this.backgroundColor = Colors.white, Key? key})
      : super(key: key);

  @override
  State<GameComponent> createState() => _GameState();
}

class _GameState extends State<GameComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor, // Define a cor de fundo
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(widget.name)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
