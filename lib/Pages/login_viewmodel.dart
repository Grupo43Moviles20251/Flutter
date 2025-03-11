 import 'package:first_app/Repositories/login_repository.dart';


class LoginViewModel {
   final LoginRepository _loginRepository;

   LoginViewModel(this._loginRepository);

   Future<void> login(String email, String password) async {
     final success = await _loginRepository.login(email, password);

   }
 }