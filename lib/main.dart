import 'package:first_app/Pages/home_page.dart';
import 'package:first_app/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs =  await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool("isLoggedIn") ??  false;

  runApp( MyApp(isLoggedIn:isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) :  super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF38677A)),
      ),
      home: isLoggedIn ?  HomePage():  LoginPage(),
    );
  }
}