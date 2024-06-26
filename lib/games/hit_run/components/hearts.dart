import 'package:app_asd_diagnostic/games/hit_run/hit_run.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/palette.dart';

class Hearts extends PositionComponent with HasGameRef<HitRun> {
  late TextComponent heartsText;
  int hearts = 3;

  Hearts({super.position});

  @override
  Future<void> onLoad() async {
    super.onLoad();
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

  void decreaseHearts() {
    hearts -= 1;
    heartsText.text = 'Hearts: $hearts';
    if (hearts <= 0) {
      print('JSON data when lives reach zero: ${gameRef.stats.toJson()}');
      gameRef.resetGame();
      gameRef.stats.endGame();
      resetHearts();
    }
  }

  void resetHearts() {
    hearts = 3;
    heartsText.text = 'Hearts: $hearts';
  }
}
