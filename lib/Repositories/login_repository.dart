import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      await _auth.signInWithCredential(credential);
      return true;
    } catch(e){
      print("Google Sign-In Error: $e");
      return false;

    }
  }


}