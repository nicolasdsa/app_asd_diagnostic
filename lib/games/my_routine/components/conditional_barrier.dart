import 'package:app_asd_diagnostic/games/my_routine/components/interactive.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:async' as dartAsync;

class ConditionalBarrier extends Interactive {
  final String requiredObjective;
  final String message; // texto a exibir se não cumprido

  ConditionalBarrier({
    required Vector2 position,
    required Vector2 size,
    required this.requiredObjective,
    this.message = "Você ainda não completou o objetivo!",
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // inicializa o _textComponent interno
    add(RectangleHitbox());
  }

  @override
  void hideText() {}

  @override
  void collidedWithPlayer() async {
    print('alo');
    // Espera-se o formato: "Frase|icons|Frase da fase|correto"

    final parts = requiredObjective.split("|");
    if (parts.length < 2) {
      // Certifique-se de que há pelo menos duas partes
      print("Formato inválido para Conditional Barrier: $requiredObjective");
      return;
    }
    final String objective = parts[0];
    final String phaseText = parts[1];

    final done = gameRef.objectives.isComplete(objective);
    if (!done) {
      gameRef.player.freeze = true;
      gameRef.player.currentDirection = 'down';
      gameRef.player.animation = gameRef.player.animations['idle'];
      await _showStageDialogue(phaseText); // Aguarda o término do diálogo
      gameRef.player.freeze = false;
    } else {
      gameRef.player.collisionBlocks.remove(this);

      removeFromParent();
    }
  }

  Future<void> _showStageDialogue(String phaseText) async {
    // Cria o texto que aparece sobre o player.
    final textComponent = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          backgroundColor: Color(0xB3FFFFFF),
        ),
      ),
      position: Vector2(0, -20),
      anchor: Anchor.bottomCenter,
    );
    textComponent.priority = 10000;
    gameRef.player.add(textComponent);

    int currentIndex = 0;
    print(phaseText);

    final completer = dartAsync.Completer<void>();

    dartAsync.Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (currentIndex < phaseText.length) {
        textComponent.text += phaseText[currentIndex];
        currentIndex++;
      } else {
        timer.cancel();
        dartAsync.Future.delayed(const Duration(seconds: 3), () {
          textComponent.removeFromParent();
          completer.complete(); // Marca o Future como concluído
        });
      }
    });

    return completer
        .future; // Retorna o Future que será concluído após o diálogo
  }
}
