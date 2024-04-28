import 'package:app_asd_diagnostic/screens/initial_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<int> formChangeNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ValueListenableBuilder(
              valueListenable: formChangeNotifier,
              builder: (context, value, child) {
                return InitialScreen(formChangeNotifier: formChangeNotifier);
              },
            ),
        // Add your new route here
        // Example: '/details': (context) => DetailsScreen(),
      },
    );
  }
}
