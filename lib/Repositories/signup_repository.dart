import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Pages/login_page.dart';

abstract class SignUpRepository{

  Future<bool> signUp(String name, String email, String password, String address, String birthday, BuildContext context);
}


class SignRepository implements SignUpRepository {

  @override
  Future<bool> signUp(String name, String email, String password, String address, String birthday, BuildContext context) async {
    try{
      var response = await http.post(
        Uri.parse('http://192.168.20.48:8000/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'birthday': birthday,
        }),
      );


      if (response.statusCode == 200){

        Future.delayed(Duration(seconds: 2), () {
          if(!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginPage()));
        });

        return true;

      }else{
        print(response.body);
        return false;
      }


    } catch(e){
      print("Google Sign-In Error: $e");
      return false;

    }
  }
  


}