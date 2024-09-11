import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackArrow;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackArrow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        leading: showBackArrow
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 20, // Change the size of the back arrow icon
              )
            : null,
        automaticallyImplyLeading: showBackArrow);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
