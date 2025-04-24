abstract class UserRepository{

  Future<String> updateUser(String name, String email, String password, String address, String birthday);
}


class userRepository implements UserRepository {
  @override
  Future<String> updateUser(String name, String email, String password, String address, String birthday) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

}

