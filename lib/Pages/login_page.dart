import 'package:first_app/Pages/login_viewmodel.dart';
import 'package:first_app/Pages/signup_page.dart';
import 'package:first_app/Repositories/login_repository.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}


class _LoginPageState extends State<LoginPage>{
  final GlobalKey<FormState>  _loginFormKey = GlobalKey();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LoginViewModel _viewModel = LoginViewModel(AuthRepository());
  bool _isObscure = false;


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
                'Login',
                style: TextStyle(
                  fontFamily: 'MontserratAlternates',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
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
                        if(value == null || value ==""){
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

                  ]

                ),

              ),

              SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Aquí irá la navegación a la pantalla de recuperación
                  },
                  child: Text("Forgot your password?", style: TextStyle(color: Color(0xFF38677A), fontFamily: 'MontserratAlternates')),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                   if(_loginFormKey.currentState?.validate()?? false){
                     _loginFormKey.currentState?.save();
                      final _email = _emailController.text;
                      final _password = _passwordController.text;
                      await _viewModel.login(_email, _password, context);
                     }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF38677A),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle( fontSize: 16),
                ),
                child: const Text('Sign in', style: TextStyle(color: Colors.white , fontFamily: 'MontserratAlternates')),
              ),

              SizedBox(height: 20),

              Text("Or you can", style: TextStyle(color: Color(0xFF38677A) , fontFamily: 'MontserratAlternates')),

              SizedBox(height: 10),

              // Botón Sign in with Google
              ElevatedButton(
                onPressed: () async {
                  await _viewModel.loginWithGoogle(context);

                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Color(0xFF38677A),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Sign in with Google", style: TextStyle(color: Colors.white, fontFamily: 'MontserratAlternates')),
                  ],
                ),
              ),


              SizedBox(height: 20),

              // Enlace "Sign Up"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Never experienced FreshLink?", style: TextStyle(fontFamily: 'MontserratAlternates')),
                  TextButton(
                    onPressed: () {
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text("Sign Up", style: TextStyle(color: Color(0xFF38677A), fontWeight: FontWeight.bold, fontFamily: 'MontserratAlternates')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}