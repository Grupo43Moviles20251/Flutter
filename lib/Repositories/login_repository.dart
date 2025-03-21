import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class LoginRepository{

  Future<bool> login(String email, String password);
  Future<bool> loginWithGoogle();
}


class AuthRepository implements LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<bool> login(String email, String password) async {
    try {

      UserCredential userCredential =  await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? token = await userCredential.user!.getIdToken();

      var response = await http.get(
        // Poner IP computador personal aca
        Uri.parse('http://192.168.0.134:8000/users/me'),

        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200){
        var userData = json.decode(response.body);

        await _saveUserData(userData);
        return true;

      }else{
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print("Auth Error: ${e.code} - ${e.message}");
      return false;
    }
  }

  // Guardar la información del usuario en SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(userData));  // Guardar como JSON
  }


  @override
  Future<bool> loginWithGoogle() async{
    try{
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;


      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      String? token = await userCredential.user!.getIdToken();

      var response = await http.get(
        // Poner IP computador personal aca
        Uri.parse('http://192.168.0.134:8000/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200){
        var userData = json.decode(response.body);
        await _saveUserData(userData);
        return true;

      }else{

        var userData = json.encode({
          'name': googleUser.displayName,
          'email': googleUser.email,
          'password': '',
          'address': '',
          'birthday': '',
        });

        var createUserResponse = await http.post(
          Uri.parse('http://192.168.0.134:8000/signup'),
          headers: {'Content-Type': 'application/json'},
          body: userData,
        );

        if (createUserResponse.statusCode == 200) {
          await _saveUserData(json.decode(createUserResponse.body));
          return true;

        } else {
          print("Error creating user: ${createUserResponse.body}");
          return false;
        }

      }
    } catch(e){
      print("Error durante el inicio de sesión con Google: ${e.toString()}");
      if (e is PlatformException) {
        print("Código de error: ${e.code}");
        print("Mensaje de error: ${e.message}");
      }
      return false;

    }
  }


}