import 'package:first_app/Repositories/signup_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Pages/login_page.dart';



class SignUpViewmodel {
  final SignUpRepository _signUpRepository;

  SignUpViewmodel(this._signUpRepository);

  Future<void> signUp(String name, String email, String password, String address, String birthday,  BuildContext context) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final success = await _signUpRepository.signUp(name,email, password, address, birthday, context);

    if(!context.mounted) return;
    Navigator.of(context).pop();
    if(success){

      Future.delayed(Duration(seconds: 2), () {
        if(!context.mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginPage()));
      });

      Fluttertoast.showToast(
        msg: "✔ Usuario registrado. Redirigiendo al login...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color(0xFF38677A),
        textColor: Colors.white,

      );
    }

  }


}
