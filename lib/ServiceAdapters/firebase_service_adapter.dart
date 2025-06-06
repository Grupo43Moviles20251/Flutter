

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseServiceAdapter {

  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<String?> getCurrentUserToken();
  Future<void> signOut();
  Future<bool> forgotPassword(String email);

  Future<void> updateEmail(String newEmail);
  Future<String> uploadProfileImage( File imageFile);
  Future<void> updateUserData(Map<String, dynamic> userData);
  
  Future<void> sendOrderAnalytics(int productId,String nameProduct, int quantity);
  Future<void> logDetailEvent(String restaurantId, String eventType);

  

}

class FirebaseServiceAdapterImpl implements FirebaseServiceAdapter{

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  FirebaseServiceAdapterImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

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

  @override
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }
  }

  @override
  Future<String> uploadProfileImage( File imageFile) async {
    final user = _auth.currentUser;
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('profile_images/${user?.uid}/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  @override
  Future<void> updateUserData( Map<String, dynamic> userData) async {
    final user = _auth.currentUser;
    await _firestore.collection('users').doc(user?.uid).set(userData, SetOptions(merge: true));
  }


  @override
  Future<void> sendOrderAnalytics(int productId, String nameProduct, int quantity) async {
    try {
      await FirebaseFirestore.instance.collection('product_orders').add({
        'productId': productId,
        'quantity': quantity,
        'date': Timestamp.now(),
        'nameProduct': nameProduct,
      });

    } catch (e) {
      print("Error al guardar la orden: $e");
    }
  }

  @override
Future<void> logDetailEvent(String restaurantId, String eventType) async {
  try {
    await FirebaseFirestore.instance.collection('detail_events').add({
      'restaurant_id': restaurantId,
      'event_type': eventType,
      'timestamp': Timestamp.now(),
    });
  } catch (e) {
    print("Error logging detail event: $e");
  }
}

}



