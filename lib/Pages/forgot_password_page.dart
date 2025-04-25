import 'package:first_app/ViewModels/forgot_password_viewmodel.dart';
import 'package:first_app/Repositories/forgot_password_repository.dart';
import 'package:flutter/material.dart';

import '../Services/connection_helper.dart';

class ForgotPasswordPage extends StatefulWidget{

  const ForgotPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordPage();
  }

}

class _ForgotPasswordPage extends State<ForgotPasswordPage>{
  final GlobalKey<FormState>  _forgotFormKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();

  final ForgotPasswordViewmodel _viewModel = ForgotPasswordViewmodel(forgotPassRepository(), ConnectivityService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: SafeArea(child: _buildUI()),
    );
  }

  Widget _buildUI() {
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
                'Reset Your Password',
                style: TextStyle(
                  fontFamily: 'MontserratAlternates',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 70),
              Form(
                key: _forgotFormKey,
                child: Column(
                    children: [

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              fontFamily: 'MontserratAlternates'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF38677A),
                                width: 2.0), // Color cuando el campo NO está enfocado
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF38677A),
                                width: 2.5), // Color cuando el campo ESTÁ enfocado
                          ),
                        ),
                      ),

                    ]

                ),

              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_forgotFormKey.currentState?.validate() ?? false) {
                    _forgotFormKey.currentState?.save();

                    final email = _emailController.text;

                    await _viewModel.forgotPassword(email, context);
                  };
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF38677A),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: const Text('Send reset link', style: TextStyle(
                    color: Colors.white, fontFamily: 'MontserratAlternates')),
              ),

              SizedBox(height: 20),



                          ],
          ),
        ),
      ),
    );
  }

}