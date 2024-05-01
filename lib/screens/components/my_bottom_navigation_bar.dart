import 'package:app_asd_diagnostic/screens/form_screen.dart';
import 'package:app_asd_diagnostic/screens/home_screen.dart';
import 'package:app_asd_diagnostic/screens/initial_screen.dart';
import 'package:app_asd_diagnostic/screens/teste.dart';
import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late ValueNotifier<int> formChangeNotifier;

  @override
  void initState() {
    super.initState();
    formChangeNotifier = ValueNotifier(0);
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      Screen1(),
      HomeScreen(formChangeNotifier: formChangeNotifier),
      FormScreen(formChangeNotifier: formChangeNotifier)
    ];

    return Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Tela Inicial',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Pacientes',
            ),
          ],
        ));
  }
}
