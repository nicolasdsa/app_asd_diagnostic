import 'package:flutter/material.dart';

class CardOption extends StatefulWidget {
  final String title;
  final IconData icon;
  final ValueChanged<String> onTap;
  const CardOption(this.title, this.icon, {required this.onTap, Key? key})
      : super(key: key);

  @override
  _CardOptionState createState() => _CardOptionState();
}

class _CardOptionState extends State<CardOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: _isPressed
            ? Colors.grey
            : Colors.white, // change color when button is pressed
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 25),
              const SizedBox(height: 15),
              Text(widget.title),
            ],
          ),
          onTapDown: (details) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (details) {
            setState(() {
              _isPressed = false;
            });
          },
          onTap: () => widget.onTap(widget.title),
        ),
      ),
    );
  }
}
