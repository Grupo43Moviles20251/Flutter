import '../Dtos/user_dto.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? address;
  final String? birthday;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.address,
    this.birthday,
  });

  factory UserModel.fromDTO(UserDTO dto) {
    return UserModel(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      address: dto.address,
      birthday: dto.birthday,
    );
  }
}