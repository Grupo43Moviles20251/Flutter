
import 'package:first_app/Repositories/forgot_password_repository.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Pages/login_page.dart';

class ForgotPasswordViewmodel {
  final ForgotPasswordRepository _forgotPasswordRepository;
  final ConnectivityService _connectivityService;

  ForgotPasswordViewmodel(this._forgotPasswordRepository, this._connectivityService);

  Future<void> forgotPassword( String email, BuildContext context) async {

    final isConnected = await _connectivityService.isConnected();
    if(!isConnected){
      if (context.mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No internet connection. Try again to send the link when you\'re back online.'),
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
