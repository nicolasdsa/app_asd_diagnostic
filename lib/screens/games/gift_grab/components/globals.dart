class Globals {
  Globals._();

  /// Audio
  static const String freezeSound = 'freeze-sound.wav';
  static const String itemGrabSound = 'item-grab-sound.wav';
  static const String flameSound = 'flame-sound.wav';

  /// Images
  static const String santaIdle = 'Gift_Grab/santa-idle.png';
  static const String santaFrozen = 'Gift_Grab/santa-frozen.png';
  static const String santaSlideLeftSprite = 'Gift_Grab/santa-slide-left.png';
  static const String santaSlideRightSprite = 'Gift_Grab/santa-slide-right.png';
  static const String backgroundSprite = 'Gift_Grab/background-sprite.jpg';
  static const String giftSprite = 'Gift_Grab/gift-sprite.png';
  static const String iceSprite = 'Gift_Grab/ice-sprite.png';
  static const String flameSprite = 'flame.png';
  static const String cookieSprite = 'cookie.png';

  static late bool isTablet = false;

  static const int gameTimeLimit = 45;
  static const int frozenTimeLimit = 3;
  static const int flameTimeLimit = 10;
  static const int cookieTimeLimit = 10;
}
