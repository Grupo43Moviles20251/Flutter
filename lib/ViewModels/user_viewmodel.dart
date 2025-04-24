// user_view_model.dart
import 'dart:io';

import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/Repositories/user_repository.dart';

class UserViewModel {
  final UserRepository _userRepository;

  UserViewModel(this._userRepository);

  Future<UserDTO> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? address,
    String? birthday,
    File? profileImage,
  }) async {

    final updatedUser = await _userRepository.updateUserProfile(
      userId: userId,
      name: name,
      email: email,
      address: address,
      birthday: birthday,
      profileImage: profileImage,
    );

    await _userRepository.saveUserLocally(updatedUser);
    return updatedUser;
  }
}