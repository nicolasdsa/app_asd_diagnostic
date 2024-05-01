import 'package:app_asd_diagnostic/db/form_dao.dart';
import 'package:app_asd_diagnostic/db/type_question_dao.dart';
import 'package:app_asd_diagnostic/screens/components/form_user.dart';
import 'package:app_asd_diagnostic/screens/components/my_bottom_navigation_bar.dart';
import 'package:app_asd_diagnostic/screens/form_screen.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatefulWidget {
  final ValueNotifier<int> formChangeNotifier;

  InitialScreen({required this.formChangeNotifier, Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final _formDao = FormDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initial Screen'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle drawer item 1 tap
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle drawer item 2 tap
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}
