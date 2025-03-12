import 'package:first_app/Repositories/signup_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



class SignUpViewmodel {
  final SignUpRepository _signUpRepository;

  SignUpViewmodel(this._signUpRepository);

  Future<void> signUp(String name, String email, String password, String address, String birthday,  BuildContext context) async {
    final success = await _signUpRepository.signUp(name,email, password, address, birthday, context);
    if(success){

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
