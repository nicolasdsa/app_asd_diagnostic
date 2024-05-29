import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame/palette.dart';

class Points extends PositionComponent {
  late TextComponent pointsText;
  int points = 0;

  Points({super.position}) {
    pointsText = TextComponent(
      text: 'Points: $points',
      textRenderer: TextPaint(
        style: TextStyle(
          color: BasicPalette.white.color,
          fontSize: 24.0,
        ),
      ),
    );
    add(pointsText);
  }

  void increasePoints() {
    points += 1;
    pointsText.text = 'Points: $points';
  }

  void resetPoints() {
    points = 0;
    pointsText.text = 'Points: $points';
  }
}
