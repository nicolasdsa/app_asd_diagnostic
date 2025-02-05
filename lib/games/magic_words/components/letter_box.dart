import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class LetterBox extends SpriteComponent with TapCallbacks, CollisionCallbacks {
  String? currentLetter; // Letra atualmente armazenada na caixa
  final String defaultSpritePath =
      'words_adventure/icons/hex_white.png'; // Sprite inicial
  late final Sprite defaultSprite;
  bool isLocked = false; // Flag para travar a letra no LetterBox
  bool hasAnimated =
      false; // Flag para controlar se a animação já foi executada

  LetterBox({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    defaultSprite = await Sprite.load(defaultSpritePath);
    sprite = defaultSprite; // Define o sprite inicial

    // Adiciona um hitbox para detectar colisões
    add(RectangleHitbox());
  }

  Future<void> setLetter(String letter, Sprite letterSprite) async {
    if (!isLocked) {
      currentLetter = letter;
      _animateSpriteChange(letterSprite);
      // Adicione um print para debug
      print('Letra definida: $letter');
    }
  }

  void _animateSpriteChange(Sprite newSprite) {
    // Animação de fade out do sprite atual
    Future.delayed(const Duration(milliseconds: 100), () {
      sprite = newSprite; // Troca o sprite
    });
  }

  void reset() {
    currentLetter = null;
    sprite = defaultSprite;
    isLocked = false;
    hasAnimated = false;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (!isLocked) {
      // Reseta para o sprite padrão quando clicado
      currentLetter = null;
      sprite = defaultSprite;
    }
    return true;
  }
}
