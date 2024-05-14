import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/widgets.dart';

JoystickComponent joystick = JoystickComponent(
    knob: CircleComponent(
      radius: 30,
      paint: BasicPalette.red.withAlpha(200).paint(),
    ),
    background: CircleComponent(
      radius: 100,
      paint: BasicPalette.red.withAlpha(100).paint(),
    ),
    margin: const EdgeInsets.only(left: 40, bottom: 40)
    // margin: const EdgeInsets.only(left: 20, bottom: 20),
    // size: 100,
    // opacityBackground: 0.5,
    // opacityKnob: 0.8,
    // spriteBackground: SpriteComponent.fromImage('joystick_background.png'),
    // spriteKnob: SpriteComponent.fromImage('joystick_knob.png'),
    // showAction: false,
    // actions: [
    //   JoystickAction(
    //     actionId: 1,
    //     sprite: SpriteComponent.fromImage('joystick_action.png'),
    //     margin: const EdgeInsets.only(right: 20, bottom: 20),
    //     size: 50,
    //   ),
    // ],
    );
