import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

abstract class SignUpRepository{

  Future<bool> signUp(String name, String email, String password, String address, String birthday, BuildContext context);
}


class SignRepository implements SignUpRepository {

  @override
  Future<bool> signUp(String name, String email, String password, String address, String birthday, BuildContext context) async {
    try{
      var response = await http.post(
        // Poner IP computador personal aca

        Uri.parse('http://34.60.49.32:8000/signup'),
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
        return true;

      }else{
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,

        );
        return false;
      }


    } catch(e){
      print("Google Sign-In Error: $e");
      return false;

    }
  }
  


}