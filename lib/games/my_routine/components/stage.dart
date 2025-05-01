// stage.dart
import 'dart:async' as dartAsync;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart'; // Para eventos de toque
import 'package:flutter/material.dart';
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'interactive.dart';

/// Componente Stage – interpreta o name com 4 parâmetros e ativa a StageScreen.
class Stage extends Interactive {
  late final String playerText; // Texto exibido acima do player.
  late final List<String>
      iconNames; // Lista de nomes das imagens (ex.: alarm-dawn-moon-soccer).
  late final String phaseText; // Texto da fase exibido na tela.
  late final List<String>
      correctIcons; // Lista de 3 ícones corretos (ex.: dawn-moon-soccer).

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
          final stageScreen = StageScreen(
            phaseText: phaseText,
            iconNames: iconNames,
            correctIcons: correctIcons,
          )..priority = 10000;
          gameRef.add(stageScreen);
        });
      }
    });
  }

  @override
  void toggleInteraction() {}
}

/// Tela Stage que exibe a frase da fase, o grid de ícones e o texto "Selecionados:"
class StageScreen extends PositionComponent with HasGameRef<MyGame> {
  final String phaseText;
  final List<String> iconNames;
  final List<String> correctIcons;

  late TextComponent selectedTextComponent;
  final List<ClickableIcon> selectedIcons = [];
  final List<ClickableIcon> allIcons = [];

  StageScreen({
    required this.phaseText,
    required this.iconNames,
    required this.correctIcons,
  });

  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    // Adiciona um fundo para destacar a tela.
    final bg = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blueGrey.withOpacity(0.3),
      anchor: Anchor.topLeft,
    );
    add(bg);

    // Exibe a frase da fase no topo central.
    final phaseTextComponent = TextComponent(
      text: phaseText,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 20),
    );
    add(phaseTextComponent);

    // Configura o grid: 2 linhas, 3 colunas.
    const double iconSize = 70;
    const double spacing = 20;
    const int columns = 3;
    const int rows = 2;
    final double gridWidth = columns * iconSize + (columns - 1) * spacing;
    final double gridHeight = rows * iconSize + (rows - 1) * spacing;
    final double startX = (size.x - gridWidth) / 2;
    final double startY = (size.y - gridHeight) / 2;

    // Cria os ícones.
    for (int i = 0; i < iconNames.length; i++) {
      final int col = i % columns;
      final int row = i ~/ columns;
      final double x = startX + col * (iconSize + spacing);
      final double y = startY + row * (iconSize + spacing);

      final sprite =
          await gameRef.loadSprite('my_routine/icons/${iconNames[i]}.png');
      final icon = ClickableIcon(
        iconName: iconNames[i],
        sprite: sprite,
        position: Vector2(x, y),
        size: Vector2.all(iconSize),
        onIconTapped: _onIconTapped,
      );
      allIcons.add(icon);
      add(icon);
    }

    // Texto na parte inferior que mostra os ícones selecionados.
    selectedTextComponent = TextComponent(
      text: "Selecionados: ",
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y - 20),
    );
    add(selectedTextComponent);
  }

  void _onIconTapped(ClickableIcon icon) {
    // Se o ícone já estiver selecionado, desmarca-o.
    if (selectedIcons.contains(icon)) {
      selectedIcons.remove(icon);
      icon.setSelected(false);
    } else {
      // Se já houver 3 selecionados, desmarca o primeiro (mais antigo).
      if (selectedIcons.length == 3) {
        final oldest = selectedIcons.removeAt(0);
        oldest.setSelected(false);
      }
      selectedIcons.add(icon);
      icon.setSelected(true);
    }
    _updateSelectedText();

    // Se houver 3 ícones selecionados, valida a resposta.
    if (selectedIcons.length == 3) {
      final selectedNames = selectedIcons.map((e) => e.iconName).toSet();
      final correctSet = correctIcons.toSet();
      if (selectedNames.containsAll(correctSet) &&
          correctSet.containsAll(selectedNames)) {
        // Se a resposta estiver correta, aguarda 2 segundos para feedback e então remove a StageScreen.
        dartAsync.Future.delayed(const Duration(seconds: 2), () {
          removeFromParent();
        });
      }
    }
  }

  void _updateSelectedText() {
    final names = selectedIcons.map((icon) => icon.iconName).join(", ");
    selectedTextComponent.text = "Selecionados: $names";
  }

  @override
  void onRemove() {
    // Ao remover a StageScreen, reativa os controles e o movimento do player.
    gameRef.add(gameRef.joystick);
    gameRef.add(gameRef.actionButton);
    gameRef.player.freeze = false;
    super.onRemove();
  }
}

/// Ícone clicável que, ao ser selecionado, exibe borda e efeito de tremida.
class ClickableIcon extends SpriteComponent
    with TapCallbacks, HasGameRef<MyGame> {
  final String iconName;
  final Function(ClickableIcon) onIconTapped;
  bool isSelected = false;
  double shakeTime = 0.0;

  ClickableIcon({
    required this.iconName,
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required this.onIconTapped,
  }) : super(sprite: sprite, position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void onTapDown(TapDownEvent event) {
    onIconTapped(this);
    super.onTapDown(event);
  }

  void setSelected(bool selected) {
    isSelected = selected;
    if (!selected) {
      angle = 0.0;
      shakeTime = 0.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isSelected) {
      shakeTime += dt;
      // Efeito de tremida: pequena oscilação na rotação.
      angle = 0.05 * sin(shakeTime * 20);
    } else {
      angle = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isSelected) {
      // Desenha uma borda ao redor do ícone.
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      final paint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rect, paint);
    }
  }
}
