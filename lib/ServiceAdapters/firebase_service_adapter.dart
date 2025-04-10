import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class FirebaseServiceAdapter {

  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<String?> getCurrentUserToken();
  Future<void> signOut();
  Future<bool> forgotPassword(String email);

}

class FirebaseServiceAdapterImpl implements FirebaseServiceAdapter{

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseServiceAdapterImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<String?> getCurrentUserToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch(e){
      return false;
    }

  }
}



