import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';
import 'package:flutter/material.dart';

abstract class ForgotPasswordRepository{

  Future<bool> forgotPassword( String email, BuildContext context);
}


class forgotPassRepository implements ForgotPasswordRepository {
  final FirebaseServiceAdapter firebaseServiceAdapter =  FirebaseServiceAdapterImpl();

  @override
  Future<bool> forgotPassword(String email, BuildContext context) async {
    return  firebaseServiceAdapter.forgotPassword(email);
}
}
