// lib/games/my_routine/components/objectives_hud.dart

import 'package:app_asd_diagnostic/games/my_routine/my_routine.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ObjectivesHud extends Component with HasGameRef<MyRoutine> {
  @override
  Future<void> onLoad() async {}

  @override
  void render(Canvas canvas) {
    final textStyle = TextPaint(
      style: TextStyle(fontSize: 14, color: Colors.white),
    );
    final entries = gameRef.objectives.all;
    double y = 10;
    for (var e in entries) {
      final mark = e.value ? "✓" : "◻";
      textStyle.render(
        canvas,
        "$mark ${e.key}",
        Vector2(10, y),
      );
      y += 18;
    }
  }

  @override
  void update(double dt) {
    // nada aqui
  }
}
