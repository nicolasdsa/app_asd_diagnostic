import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';

class Interactive extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final String phrase;
  late TextComponent _textComponent;
  bool _isShowingText = false;
  String _displayText = '';
  int _currentCharIndex = 0;
  bool get isTextActive => _isShowingText;

  Interactive({this.phrase = 'Cama', position, size})
      : super(
            position: position,
            size: size,
            priority: 1000); // Ajuste a prioridade aqui

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());

    // Criar componente de texto
    _textComponent = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          backgroundColor: Colors.white.withOpacity(0.7),
        ),
      ),
      position: Vector2(0, -20), // posição relativa ao player
    );
    _textComponent.priority = 999;

    return super.onLoad();
  }

  void collidedWithPlayer() {
    print('Você está próximo de: $phrase');
  }

  void toggleInteraction() {
    if (!_isShowingText) {
      _startTextReveal();
    } else {
      hideText();
    }
  }

  void _startTextReveal() {
    _isShowingText = true;
    _currentCharIndex = 0;
    _displayText = '';
    (gameRef).player.add(_textComponent);

    gameRef.add(TimerComponent(
      period: 0.05, // Velocidade da escrita
      repeat: true,
      onTick: () {
        if (_currentCharIndex < phrase.length) {
          _displayText += phrase[_currentCharIndex];
          _textComponent.text = _displayText;
          _currentCharIndex++;
        } else {
          children.removeWhere((child) => child is TimerComponent);
        }
      },
    ));
  }

  void hideText() {
    _isShowingText = false;
    _textComponent.text = '';
    _textComponent.removeFromParent();
  }
}
