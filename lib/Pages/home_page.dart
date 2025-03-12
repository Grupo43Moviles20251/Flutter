import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePagePageState();
  }

}

class _HomePagePageState extends State<HomePage>{


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
            child: Column(
              children: [
                const Text("Olis"),
                ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove("userData");
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                      
                    },
                    child: const Text("SignOff"))
              ],
            )),
      ),
    );
  }

}