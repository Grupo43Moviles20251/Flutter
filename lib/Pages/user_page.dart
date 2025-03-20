import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class UserPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child:  PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
                child: Column(
                  children: [

                    ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove("userData");
                          await prefs.remove("isLoggedIn");
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
        ),
      ),
      selectedIndex: 0,
    );
  }
}