// lib/games/go_no_go/components/target.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum TargetState { initial, go, noGo }

class Target extends PositionComponent {
  TargetState state = TargetState.initial;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2.all(100);
    anchor = Anchor.center;
    _updateColor();
  }

  void _updateColor() {
    final paint = Paint();
    switch (state) {
      case TargetState.go:
        paint.color = Colors.green;
        break;
      case TargetState.noGo:
        paint.color = Colors.red;
        break;
      default:
        paint.color = Colors.grey;
    }
    // Remove o filho anterior (se houver) e adiciona um novo círculo
    removeAll(children);
    add(CircleComponent(radius: size.x / 2, paint: paint));
  }

  void setGo() {
    state = TargetState.go;
    _updateColor();
    // Adicione animação de piscar se desejar
  }

  void setNoGo() {
    state = TargetState.noGo;
    _updateColor();
  }

  void reset() {
    state = TargetState.initial;
    _updateColor();
  }
}
