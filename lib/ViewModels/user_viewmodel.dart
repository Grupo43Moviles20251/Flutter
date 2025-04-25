// user_view_model.dart
import 'dart:io';

import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/Repositories/user_repository.dart';

class UserViewModel {
  final UserRepository _userRepository;

  UserViewModel(this._userRepository);

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
      existingImageUrl : existingImageUrl
    );

    await _userRepository.saveUserLocally(updatedUser);
    return updatedUser;
  }
}