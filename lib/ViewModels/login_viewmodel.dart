import 'package:first_app/Pages/home_page.dart';
import 'package:first_app/Repositories/login_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/connection_helper.dart';


class LoginViewModel {
   final LoginRepository _loginRepository;
   final ConnectivityService _connectivityService;

   LoginViewModel(this._loginRepository, this._connectivityService);

   Future<void> login(String email, String password, BuildContext context) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if(!isConnected){
        if (context.mounted) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No internet connection. Try again to login when you\'re back online.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final result = await _loginRepository.login(email, password);

      if(!context.mounted) return;
      Navigator.of(context).pop();

      if (result == "Success") {
        final prefs =  await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if(!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>  HomePageWrapper(selectedIndex: 0,),
              settings: RouteSettings(name: "HomePage")
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid Credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }

      }
    catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              duration: Duration(seconds: 3),
            ));
        }
        }
    }


   Future<void> loginWithGoogle( BuildContext context) async{
     try {
     final isConnected = await _connectivityService.isConnected();
     if(!isConnected){


       if (context.mounted) {

         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('No internet connection. Try again to login when you\'re back online.'),
             duration: Duration(seconds: 3),
           ),
         );
       }
       return;
     }
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context) {
         return Center(
           child: CircularProgressIndicator(),
         );
       },
     );

     final result =  await _loginRepository.loginWithGoogle();
     if(!context.mounted) return;
     Navigator.of(context).pop();

     if(result ==  "Success"){
       final prefs =  await SharedPreferences.getInstance();
       await prefs.setBool('isLoggedIn', true);

       if(!context.mounted) return;

       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
             builder: (context) =>  HomePageWrapper(),
             settings: RouteSettings(name: "HomePage")
         ),
       );

     }
     else{
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(result ?? 'Invalid Credentials'),
           backgroundColor:  const Color(0xFF38677A),
         ),
       );
     }
   }
     catch (e) {
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Login failed: ${e.toString()}'),
               duration: Duration(seconds: 3),
             ));
       }
     }
   }
 }
