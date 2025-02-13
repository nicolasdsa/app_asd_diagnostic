import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Tip extends PositionComponent {
  final String tip;
  final Vector2 screenSize;

  Tip({
    required this.tip,
    required this.screenSize,
  }) {
    // Posiciona a dica no centro inferior da tela
    position = Vector2(screenSize.x / 2, screenSize.y - 40);
    size = Vector2(300, 50);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      TextComponent(
        text: "Dica: $tip",
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..anchor = Anchor.center,
    );
  }
}
