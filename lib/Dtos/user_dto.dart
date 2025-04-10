class UserDTO {
  final String? id;
  final String name;
  final String email;
  final String? address;
  final String? birthday;

  UserDTO({
    this.id,
    required this.name,
    required this.email,
    this.address,
    this.birthday,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString(),
      birthday: json['birthday']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    if (address != null) 'address': address,
    if (birthday != null) 'birthday': birthday,
  };
}