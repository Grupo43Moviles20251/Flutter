// user_repository.dart
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/ServiceAdapters/firebase_service_adapter.dart';
import 'package:first_app/Dtos/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserRepository {
  Future<UserDTO> updateUserProfile({
    required String name,
    required String email,
    String? address,
    String? birthday,
    File? profileImage,
    String? existingImageUrl,
  });

  Future<void> saveUserLocally(UserDTO user);
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseServiceAdapter _firebaseService = FirebaseServiceAdapterImpl();

  UserRepositoryImpl();

  @override
  Future<UserDTO> updateUserProfile({
    required String name,
    required String email,
    String? address,
    String? birthday,
    File? profileImage,
    String? existingImageUrl,
  }) async {
    String? photoUrl;

    // Upload new profile image if provided
    if (profileImage != null) {
      photoUrl = await _firebaseService.uploadProfileImage( profileImage);
    }
    else{
      photoUrl = existingImageUrl;
    }

    // Update email if changed
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && email != currentUser.email) {
      await _firebaseService.updateEmail(email);
    }

    // Prepare user data
    final userData = {
      'name': name,
      'email': email,
      'address': address,
      'birthday': birthday,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };

    await _firebaseService.updateUserData( userData);

    return UserDTO.fromJson(userData);
  }

  @override
  Future<void> saveUserLocally(UserDTO user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(user.toJson()));
  }
}