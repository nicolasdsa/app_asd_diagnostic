import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/palette.dart';

class TimerDisplay extends PositionComponent with HasGameRef<HitRun> {
  late TextComponent timerText;
  double timer = 5.0;

  TimerDisplay({super.position}) {
    timerText = TextComponent(
      text: 'Timer: ${timer.toStringAsFixed(1)}',
      textRenderer: TextPaint(
        style: TextStyle(
          color: BasicPalette.white.color,
          fontSize: 24.0,
        ),
      ),
    );
    add(timerText);
  }

  void resetTimer() {
    timer = 5.0;
    timerText.text = 'Timer: ${timer.toStringAsFixed(1)}';
  }

  void updateTimer(double dt) {
    timer -= dt;
    if (timer < 0) {
      timer = 0;
    }
    timerText.text = 'Timer: ${timer.toStringAsFixed(1)}';
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateTimer(dt);
    if (timer <= 0) {
      gameRef.level.handleTimerEnd(); // Notify the level when the timer ends
    }
  }
}
