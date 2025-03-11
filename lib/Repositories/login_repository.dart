import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginRepository{

  Future<bool> login(String email, String password);
}


class AuthRepository implements LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print("Auth Error: ${e.code} - ${e.message}");
      return false;
    }
  }
}