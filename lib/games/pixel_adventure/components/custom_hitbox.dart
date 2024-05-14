class CustomHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });

  bool contains(double x, double y) {
    return x >= offsetX &&
        x <= offsetX + width &&
        y >= offsetY &&
        y <= offsetY + height;
  }
}
