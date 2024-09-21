import 'package:flutter/material.dart';

class CardOption extends StatefulWidget {
  final String title;
  final IconData icon;
  final ValueChanged<String> onTap;
  final ValueNotifier<String?> nameNotifier;

  const CardOption(
    this.title,
    this.icon, {
    required this.onTap,
    required this.nameNotifier,
    Key? key,
  }) : super(key: key);

  @override
  CardOptionState createState() => CardOptionState();
}

class CardOptionState extends State<CardOption> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.nameNotifier,
      builder: (context, name, _) {
        return Expanded(
          child: InkWell(
            onTap: () => widget.onTap(widget.title),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: (name == widget.title) ? Colors.white : Colors.grey[200],
                boxShadow: (name == widget.title)
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 18),
                  const SizedBox(width: 10),
                  Text(widget.title,
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
