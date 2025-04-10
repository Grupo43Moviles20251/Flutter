
import 'package:first_app/Repositories/forgot_password_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Pages/login_page.dart';

class ForgotPasswordViewmodel {
  final ForgotPasswordRepository _forgotPasswordRepository;

  ForgotPasswordViewmodel(this._forgotPasswordRepository);

  Future<void> forgotPassword( String email, BuildContext context) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final success = await _forgotPasswordRepository.forgotPassword(email, context);

    if(!context.mounted) return;
    Navigator.of(context).pop();
    if(success){
      Future.delayed(Duration(seconds: 2), () {
        if(!context.mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginPage()));
      });

      Fluttertoast.showToast(
        msg: "Se ha enviado un correo para restablecer tu contraseña",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else{
      Fluttertoast.showToast(
        msg: "Error al enviar el mensaje",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

  }


}
