// stage.dart
import 'dart:async' as dartAsync;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'interactive.dart';

/// Componente Stage – interpreta o name com 4 parâmetros e ativa a StageScreen.
class Stage extends Interactive {
  late final String playerText; // Texto exibido acima do player.
  late final List<String>
      iconNames; // Lista de nomes das imagens (ex.: alarm-dawn-moon-soccer).
  late final String phaseText; // Texto da fase exibido na tela.
  late final List<String>
      correctIcons; // Lista de 3 ícones corretos (ex.: dawn-moon-soccer).
  late final String id; // ID da fase, usado para completar o objetivo.

  bool _activated = false; // Evita múltiplas ativações.

  Stage({required String phrase, Vector2? position, Vector2? size})
      : super(phrase: phrase, position: position, size: size);

  @override
  void collidedWithPlayer() {
    if (_activated) return;
    _activated = true;

    // Espera-se o formato: "Frase|icons|Frase da fase|correto"
    final parts = phrase.split("|");
    if (parts.length < 4) {
      print("Formato inválido para Stage: $phrase");
      return;
    }
    playerText = parts[0];
    iconNames = parts[1].split("-"); // Ex.: ['alarm', 'dawn', 'moon', 'soccer']
    phaseText = parts[2];
    correctIcons = parts[3].split("-"); // Ex.: ['dawn', 'moon', 'soccer']
    id = parts[4]; // ID da fase, usado para completar o objetivo.

    _showStageDialogue();
  }

  void _showStageDialogue() {
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
    dartAsync.Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (currentIndex < playerText.length) {
        textComponent.text += playerText[currentIndex];
        currentIndex++;
      } else {
        timer.cancel();
        dartAsync.Future.delayed(const Duration(seconds: 3), () {
          textComponent.removeFromParent();
          // Remove os controles (joystick e botão) da árvore.
          gameRef.joystick.removeFromParent();
          gameRef.actionButton.removeFromParent();
          // Congela o movimento do player.
          gameRef.player.freeze = true;
          // Adiciona a StageScreen com os parâmetros lidos.
          // para na engine e mostra overlay Flutter
          gameRef.pauseEngine();
          gameRef.currentPhaseText = playerText;
          gameRef.currentIconNames = iconNames;
          gameRef.currentCorrectIcons = correctIcons;
          gameRef.currentStageId = id;
          gameRef.currentImmediateFeedback =
              false; // ou false, conforme a flag que você queira

          gameRef.pauseEngine();
          gameRef.overlays.add('StageOverlay');
        });
      }
    });
  }

  @override
  void toggleInteraction() {}
}
