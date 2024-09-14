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
        style: TextStyle(color: BasicPalette.white.color, fontSize: 18),
      ),
    );
    add(pointsText);
  }

  void addPoints(int value) {
    points += value;
    pointsText.text = 'Points: $points';
  }

  int getTotalPoints() {
    return points;
  }

  void resetPoints() {
    points = 0;
    pointsText.text = 'Points: $points';
  }
}
