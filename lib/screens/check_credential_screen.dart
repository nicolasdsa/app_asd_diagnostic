import 'package:app_asd_diagnostic/screens/hash_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialCheckScreen extends StatefulWidget {
  const InitialCheckScreen({super.key});

  @override
  InitialCheckScreenState createState() => InitialCheckScreenState();
}

class InitialCheckScreenState extends State<InitialCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkPreferences();
  }

  Future<void> _checkPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    bool? isHash = prefs.getBool('isHash');
    String? hash = prefs.getString('hash');

    if (isLoggedIn == true) {
      Navigator.pushReplacementNamed(context, '/initial');
    } else if (isHash == true && hash != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HashDataScreen(hash: hash)),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
