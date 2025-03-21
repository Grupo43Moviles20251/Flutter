 import 'package:first_app/Pages/home_page.dart';
import 'package:first_app/Repositories/login_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginViewModel {
   final LoginRepository _loginRepository;

   LoginViewModel(this._loginRepository);

   Future<void> login(String email, String password, BuildContext context) async {

     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context) {
         return Center(
           child: CircularProgressIndicator(),
          );
         },
     );

     final success = await _loginRepository.login(email, password);



     if(!context.mounted) return;
     Navigator.of(context).pop();

     if (success) {
       final prefs =  await SharedPreferences.getInstance();
       await prefs.setBool('isLoggedIn', true);

       if(!context.mounted) return;
       // Navigate to home page if login is successfull
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
             builder: (context) =>  HomePage(),
             settings: RouteSettings(name: "HomePage")
         ),
       );
     } else {
       // Show an error message or handle the failure
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
             content: Text('Invalid Credentials'),
            backgroundColor:  Colors.red,
         ),
       );
     }


   }


   Future<void> loginWithGoogle( BuildContext context) async{
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context) {
         return Center(
           child: CircularProgressIndicator(),
         );
       },
     );

     final success =  await _loginRepository.loginWithGoogle();
     if(!context.mounted) return;
     Navigator.of(context).pop();
     if(success){
       final prefs =  await SharedPreferences.getInstance();
       await prefs.setBool('isLoggedIn', true);

       if(!context.mounted) return;
       // Navigate to home page if login is successfull
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
             builder: (context) =>  HomePage(),
             settings: RouteSettings(name: "FavoritesPage")
         ), // Replace HomePage with your target page
       );

     }
     else{
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Invalid Credentials'),
           backgroundColor:  Color(0xFF38677A),
         ),
       );
     }
   }
 }