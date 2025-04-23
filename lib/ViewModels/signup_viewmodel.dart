import 'package:first_app/Repositories/signup_repository.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Pages/login_page.dart';



class SignUpViewmodel {
  final SignUpRepository _signUpRepository;
  final ConnectivityService _connectivityService;

  SignUpViewmodel(this._signUpRepository, this._connectivityService);

  Future<void> signUp(String name, String email, String password, String address, String birthday,  BuildContext context) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if(!isConnected){
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No internet connection. Try again to signup when you\'re back online.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final success = await _signUpRepository.signUp(
          name, email, password, address, birthday, context);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (success == "Success") {
        Future.delayed(Duration(seconds: 2), () {
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => LoginPage(),
              settings: RouteSettings(name: "LoginPage")
          )
          );
        });

        Fluttertoast.showToast(
          msg: "✔ Usuario registrado. Redirigiendo al login...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Color(0xFF38677A),
          textColor: Colors.white,

        );
      } else {
        Fluttertoast.showToast(
          msg: success,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,

        );
      }
    }
    catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              duration: Duration(seconds: 3),
            ));
      }
    }
  }


}
