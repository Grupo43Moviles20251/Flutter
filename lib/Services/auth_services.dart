import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _singleton = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService._internal();


  factory AuthService(){
    return _singleton;
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Success");
      return true;
    }
    on FirebaseAuthException catch (e) {
      print(password);
      print("Auth Error: ${e.code} - ${e.message}");
      return false;
    }
  }

}