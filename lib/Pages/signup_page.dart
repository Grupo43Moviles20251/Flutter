import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:first_app/Pages/login_page.dart';
import 'package:first_app/ViewModels/signup_viewmodel.dart';
import 'package:first_app/Repositories/signup_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Services/connection_helper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  bool _isObscure = false;
  bool _isLoading = false;
  DateTime? _selectedDate;
  final _connectivityService = ConnectivityService();

  final int _minAge = 13;
  final int _maxAge = 120;
  final int _nameMaxLength = 20;
  final int _emailMaxLength = 50;
  final int _passwordMinLength = 6;
  final int _passwordMaxLength = 30;
  final int _addressMaxLength = 100;

  @override
  void initState() {
    super.initState();
    // Initialize connectivity stream
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) {
      setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? now.subtract(Duration(days: _minAge * 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(Duration(days: _maxAge * 365)),
      lastDate: now.subtract(Duration(days: _minAge * 365)),
      helpText: 'Select your birthday',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldLabelText: 'Birthday',
      fieldHintText: 'Month/Day/Year',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _signUp() async {
    if (!(_signUpFormKey.currentState?.validate() ?? false)) return;
    print("NO FUNCIONO pasa el if");
    final hasInternet = await _connectivityService.isConnected();
    print(hasInternet);
    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection. Please check your connection and try again.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final address = _addressController.text;
      final birthday = _birthdayController.text;

      final viewModel = SignUpViewModel(SignUpRepositoryImpl(), ConnectivityService());
      await viewModel.signUp(name, email, password, address, birthday, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during sign up: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _checkInternetConnection(),
          builder: (context, snapshot) {
            final hasInternet = snapshot.data ?? true;

            return Column(
              children: [
                if (!hasInternet)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red,
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'No internet connection',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _buildUI(hasInternet),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildUI(bool hasInternet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/logo.png', height: 120),
              SizedBox(height: 24),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontFamily: 'MontserratAlternates',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _signUpFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      maxLength: _nameMaxLength,
                      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                      validator: (value) {
                        if (value == null || value == "") {
                          return "Enter a valid name";
                        }
                        if (value.length > _nameMaxLength) {
                          return "Name must be at most $_nameMaxLength characters";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: _emailMaxLength,
                      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                      validator: (value) {
                        if (value == null || !value.contains("@")) {
                          return "Enter a valid email";
                        }
                        if (value.length > _emailMaxLength) {
                          return "Email must be at most $_emailMaxLength characters";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isObscure,
                      maxLength: _passwordMaxLength,
                      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                      validator: (value) {
                        if (value == null || value == "") {
                          return "Enter a valid password";
                        }
                        if (value.length < _passwordMinLength) {
                          return "Password must be at least $_passwordMinLength characters";
                        }
                        if (value.length > _passwordMaxLength) {
                          return "Password must be at most $_passwordMaxLength characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF38677A),
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLength: _addressMaxLength,
                      buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                      validator: (value) {
                        if (value == null || value == "") {
                          return "Enter a valid address";
                        }
                        if (value.length > _addressMaxLength) {
                          return "Address must be at most $_addressMaxLength characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Address",
                        labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthdayController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select your birthday";
                        }
                        if (_selectedDate == null) {
                          return "Invalid date selected";
                        }
                        final DateTime now = DateTime.now();
                        final DateTime minDate = DateTime(now.year - _maxAge, now.month, now.day);
                        final DateTime maxDate = DateTime(now.year - _minAge, now.month, now.day);

                        if (_selectedDate!.isBefore(minDate)) {
                          return "You must be younger than $_maxAge years";
                        }
                        if (_selectedDate!.isAfter(maxDate)) {
                          return "You must be at least $_minAge years old";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Birthday",
                        labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5),
                        ),
                        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF38677A)),
                        hintText: 'YYYY-MM-DD',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF38677A),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'MontserratAlternates',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "If you already have an account ",
                    style: TextStyle(fontFamily: 'MontserratAlternates'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!context.mounted){

                        return;}
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Color(0xFF38677A),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MontserratAlternates',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}