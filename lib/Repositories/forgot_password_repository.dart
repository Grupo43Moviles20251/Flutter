import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class ForgotPasswordRepository{

  Future<bool> forgotPassword( String email, BuildContext context);
}


class forgotPassRepository implements ForgotPasswordRepository {


  @override
  Future<bool> forgotPassword(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);

      return false;
    }



}
}
