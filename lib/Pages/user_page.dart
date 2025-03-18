import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Text(
          "Aquí puedes agregar tu perfil de usuario",  
          style: TextStyle(fontSize: 20),
        ),
      ),
      selectedIndex: 0,
    );
  }
}