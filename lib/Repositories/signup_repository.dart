import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ServiceAdapters/backend_service_adapter.dart';

abstract class SignUpRepository{

  Future<String> signUp(String name, String email, String password, String address, String birthday, BuildContext context);
}


class SignRepository implements SignUpRepository {

  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://34.60.49.32:8000', client: http.Client());

  @override
  Future<String> signUp(String name, String email, String password, String address, String birthday, BuildContext context) async {
    try{

      final result = await backendServiceAdapter.signUp(name, email, password, address, birthday);
      return result ;
    } catch(e){
      return e.toString();

    }
  }
  


}