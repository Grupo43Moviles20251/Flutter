import 'dart:io';
import 'package:flutter/material.dart';
import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/Repositories/user_repository.dart';
import 'package:first_app/Services/connection_helper.dart';

class UserViewModel with ChangeNotifier {
  final UserRepository _userRepository;
  final ConnectivityService _connectivityService;

  UserDTO? userData;
  bool _isLoading = true;
  bool _isOnline = true;

  UserViewModel(this._userRepository, this._connectivityService) {
    _init();
  }
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  Future<void> _init() async {
    await _loadUserData();
    _initConnectivityListener();
  }

  Future<void> _loadUserData() async {
    try {
      _setLoading(true);
      final user = await _userRepository.getLocalUser();
      userData = user;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadUserData() async {
    if (await _connectivityService.isConnected()) {
      try {
        _setLoading(true);
        await _loadUserData();
      } catch (e) {
        debugPrint('Error reloading user data: $e');
      } finally {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setOnline(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  void _initConnectivityListener() {
    // Check initial status
    _connectivityService.isConnected().then(_setOnline);

    // Listen for changes
    _connectivityService.connectivityStream.listen((_) async {
      final isNowOnline = await _connectivityService.isConnected();
      _setOnline(isNowOnline);

      if (isNowOnline) {
        await reloadUserData();
      }
    });
  }

  Future<UserDTO> updateProfile({
    required String name,
    required String email,
    String? address,
    String? birthday,
    File? profileImage,
    String? existingImageUrl,
  }) async {
    final updatedUser = await _userRepository.updateUserProfile(
      name: name,
      email: email,
      address: address,
      birthday: birthday,
      profileImage: profileImage,
      existingImageUrl: existingImageUrl,
    );

    userData = updatedUser;
    notifyListeners();
    return updatedUser;
  }

  Future<void> logout() async {
    try {
      await _userRepository.logout();
      userData = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }
}