import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/palette.dart';

class Hearts extends PositionComponent with HasGameRef<HitRun> {
  late TextComponent heartsText;
  late int hearts;

  Hearts({super.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    hearts = gameRef.properties['Vidas'] as int;
    heartsText = TextComponent(
      text: 'Hearts: $hearts',
      textRenderer: TextPaint(
        style: TextStyle(
          color: BasicPalette.white.color,
          fontSize: 24.0,
        ),
      ),
    );
    add(heartsText);
  }

  void decreaseHearts(String cause) {
    gameRef.stats.causeOfLose.add(cause);

    hearts -= 1;
    heartsText.text = 'Hearts: $hearts';
    if (hearts <= 0) {
      gameRef.resetGame();
      resetHearts();
    }
  }

  void resetHearts() {
    hearts = gameRef.properties['Vidas'] as int;
    heartsText.text = 'Hearts: $hearts';
  }
}
