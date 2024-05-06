import 'package:app_asd_diagnostic/screens/form_screen.dart';
import 'package:app_asd_diagnostic/screens/home_screen.dart';
import 'package:app_asd_diagnostic/screens/patients_screen.dart';
import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late ValueNotifier<int> formChangeNotifier;
  late ValueNotifier<int> patientChangeNotifier;

  @override
  void initState() {
    super.initState();
    formChangeNotifier = ValueNotifier(0);
    patientChangeNotifier = ValueNotifier(0);
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      FormScreen(formChangeNotifier: formChangeNotifier),
      HomeScreen(formChangeNotifier: formChangeNotifier),
      PatientScreen(patientChangeNotifier: patientChangeNotifier)
    ];

    return Scaffold(
        body: children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Tela Inicial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Pacientes',
            ),
          ],
        ));
  }
}
