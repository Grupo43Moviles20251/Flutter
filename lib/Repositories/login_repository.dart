import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/ServiceAdapters/backend_service_adapter.dart';
import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class LoginRepository{

  Future<String?> login(String email, String password);
  Future<String?> loginWithGoogle();
  Future<void> logout();
}


class AuthRepository implements LoginRepository {

  final FirebaseServiceAdapter firebaseServiceAdapter =  FirebaseServiceAdapterImpl();
  final BackendServiceAdapter backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://34.60.49.32:8000', client: http.Client());


  @override
  Future<String> login(String email, String password) async {
    try {
      await firebaseServiceAdapter.signInWithEmailAndPassword(email, password);

      final token = await firebaseServiceAdapter.getCurrentUserToken();
      if (token == null) return "Error: Cannot get auth token";

      try {
        final userDTO = await backendServiceAdapter.getUserProfile(token);
        await _saveUserData(userDTO);
        return "Success";
      } catch (e) {
        return " Error connection with the server: ${e.toString()}";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "Error: User not found";
        case 'wrong-password':
          return "Error: Wrong Password";
        case 'invalid-email':
          return "Error: Invalid email";
        case 'user-disabled':
          return "Error: User Disabled";
        default:
          return "Authentication Error: ${e.message ?? 'Authentication Error'}";
      }
    } on http.ClientException catch (e) {
      return "Error in connection: ${e.message }";
    } catch (e) {
      return "Unexpected error: ${e.toString()}";
    }
  }


  Future<void> _saveUserData(UserDTO userDTO) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(userDTO.toJson()));
  }


  @override
  Future<String> loginWithGoogle() async{
    try {
      await firebaseServiceAdapter.signInWithGoogle();

      // Obtener token
      final token = await firebaseServiceAdapter.getCurrentUserToken();
      if (token == null) return "No token available";

      try {
        final userDTO = await backendServiceAdapter.getUserProfile(token);
        await _saveUserData(userDTO);
        return "Success";
      } on Exception {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) return "There is not Firebase user";


        final newUserDTO = UserDTO(name: firebaseUser.displayName ?? 'Unknown',
            email: firebaseUser.email ?? '');
        final createdUserDTO = await backendServiceAdapter.createUser(
            newUserDTO, token);
        await _saveUserData(createdUserDTO);
        return "Success";
      }
    } catch(e){
      return "Authentication Error";
    }
  }

  @override
  Future<void> logout() async{
    try{
      await firebaseServiceAdapter.signOut();
      SharedPreferences shared =  await SharedPreferences.getInstance();
      await shared.remove('userData');

    } catch(e){
      return;
    }
  }


}