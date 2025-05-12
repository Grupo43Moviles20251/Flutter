import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dtos/user_dto.dart';
import '../ServiceAdapters/firebase_service_adapter.dart';

class UserRepository  {
  final FirebaseServiceAdapter _firebaseService;
  late SharedPreferences _prefs;

  UserRepository() : _firebaseService = FirebaseServiceAdapterImpl() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<UserDTO> updateUserProfile({
    required String name,
    required String email,
    String? address,
    String? birthday,
    File? profileImage,
    String? existingImageUrl,
  }) async {
    String? photoUrl;

    if (profileImage != null) {
      photoUrl = await _firebaseService.uploadProfileImage(profileImage);
    } else {
      photoUrl = existingImageUrl;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && email != currentUser.email) {
      await _firebaseService.updateEmail(email);
    }

    final userData = {
      'name': name,
      'email': email,
      'address': address,
      'birthday': birthday,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };

    await _firebaseService.updateUserData(userData);

    final updatedUser = UserDTO.fromJson(userData);
    await saveUserLocally(updatedUser);

    return updatedUser;
  }

  Future<void> saveUserLocally(UserDTO user) async {
    await _initPrefs();
    await _prefs.setString('userData', json.encode(user.toJson()));
  }

  Future<UserDTO?> getLocalUser() async {
    await _initPrefs();
    final userJson = _prefs.getString('userData');
    return userJson != null ? UserDTO.fromJson(json.decode(userJson)) : null;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await clearLocalUser();
  }

  Future<void> clearLocalUser() async {
    await _initPrefs();
    await _prefs.remove('userData');
    await _prefs.remove('isLoggedIn');
  }
}