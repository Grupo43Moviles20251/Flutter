import 'package:first_app/Repositories/signup_repository.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Pages/login_page.dart';

class SignUpViewModel with ChangeNotifier {
  final SignUpRepository _signUpRepository;
  final ConnectivityService _connectivityService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SignUpViewModel(this._signUpRepository, this._connectivityService);

  Future<void> signUp(
      String name,
      String email,
      String password,
      String address,
      String birthday,
      BuildContext context,
      ) async {
    try {
      _setLoading(true);
      _setError(null);

      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        _setError('No internet connection. Try again to signup when you\'re back online.');
        return;
      }

      final result = await _signUpRepository.signUp(
        name,
        email,
        password,
        address,
        birthday,
      );

      if (result == "Success") {
        _showSuccessToast();
        _navigateToLogin(context);
      } else {
        _setError(result);
        _showErrorToast(result);
      }
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _showSuccessToast() {
    Fluttertoast.showToast(
      msg: "✔ Usuario registrado. Redirigiendo al login...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Color(0xFF38677A),
      textColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _navigateToLogin(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
          settings: RouteSettings(name: "LoginPage"),
        ),
      );
    });
  }
}