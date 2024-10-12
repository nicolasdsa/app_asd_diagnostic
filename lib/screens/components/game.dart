import 'package:flutter/material.dart';

class GameComponent extends StatefulWidget {
  final String name;
  final String link;
  final String path;
  final String shortDescription;
  final int id;
  final Color backgroundColor;

  const GameComponent(this.name, this.link,
      {required this.id,
      required this.path,
      required this.shortDescription,
      this.backgroundColor = Colors.white,
      Key? key})
      : super(key: key);

  @override
  State<GameComponent> createState() => _GameState();
}

class _GameState extends State<GameComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: const Border(
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Image.asset(widget.path),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.shortDescription,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
