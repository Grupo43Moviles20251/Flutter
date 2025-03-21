import 'package:first_app/Pages/login_page.dart';
import 'package:first_app/ViewModels/signup_viewmodel.dart';
import 'package:first_app/Repositories/signup_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget{
  const SignUpPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }

}

class _SignUpPageState extends State<SignUpPage>{

  final GlobalKey<FormState>  _signUpFormKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  bool _isObscure = false;
  DateTime? _selectedDate;


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }


  final SignUpViewmodel _viewModel = SignUpViewmodel(SignRepository());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildUI()),
    );
  }

  Widget _buildUI(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child : Center (
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
                        validator: (value){
                          if(value == null || value == ""){
                            return "Enter a valid name";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0), // Color cuando el campo NO está enfocado
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5), // Color cuando el campo ESTÁ enfocado
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value){
                          if(value == null || !value.contains("@")){
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(fontFamily: 'MontserratAlternates'),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF38677A), width: 2.0), // Color cuando el campo NO está enfocado
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF38677A), width: 2.5), // Color cuando el campo ESTÁ enfocado
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isObscure,

                        validator: (value){
                          if(value == null || value =="" || value.length < 6){
                            return "Enter a valid password";
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
                              color: Color(0xFF38677A), // Color del icono de visibilidad
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

                        validator: (value){
                          if(value == null || value ==""){
                            return "Enter a valid address";
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
                          if (value == null || value == "") {
                            return "Enter a valid date";
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

                        ),
                        readOnly: true,
                        onTap: (){
                          _selectDate(context);
                        },
                      ),

                    ]

                ),

              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if(_signUpFormKey.currentState?.validate()?? false){
                    _signUpFormKey.currentState?.save();
                    final name =  _nameController.text;
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    final address = _addressController.text;
                    final birthday = _birthdayController.text;
                    await _viewModel.signUp(name, email,password,address,birthday, context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF38677A),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle( fontSize: 16),
                ),
                child: const Text('Sign Up', style: TextStyle(color: Colors.white , fontFamily: 'MontserratAlternates')),
              ),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("If you already have an account ", style: TextStyle(fontFamily: 'MontserratAlternates')),
                  TextButton(
                    onPressed: () {
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text("Log In", style: TextStyle(color: Color(0xFF38677A), fontWeight: FontWeight.bold, fontFamily: 'MontserratAlternates')),
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