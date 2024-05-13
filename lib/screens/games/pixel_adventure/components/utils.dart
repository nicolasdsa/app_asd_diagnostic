bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.position.x;
  final blocktY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Check if the player is flipped horizontally and adjust the position
  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;

  // Check if the player is on a platform and adjust the position
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  // Check if the player is colliding with the block
  // playerY < blocktY + blockHeight is the player is above the block
  // playerY + playerHeight > blocktY is the player is below the block
  // playerX < blockX + blockWidth is the player is to the left of the block
  // playerX + playerWidth > blockX is the player is to the right of the block
  return (fixedY < blocktY + blockHeight &&
      fixedY + playerHeight > blocktY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
}
