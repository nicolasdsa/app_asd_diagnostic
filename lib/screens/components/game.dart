import 'package:flutter/material.dart';

class GameComponent extends StatefulWidget {
  final String name;
  final String link;
  final int id; // Add this line

  const GameComponent(this.name, this.link, {required this.id, Key? key})
      : super(key: key);

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
