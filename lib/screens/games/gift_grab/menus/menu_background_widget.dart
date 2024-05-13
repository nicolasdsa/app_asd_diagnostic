import 'package:app_asd_diagnostic/screens/games/gift_grab/components/globals.dart';
import 'package:flutter/material.dart';

class MenuBackgroundWidget extends StatelessWidget {
  const MenuBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/${Globals.backgroundSprite}"),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}
