import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HomePagePageState();
  }

}

class _HomePagePageState extends State<HomePage>{


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(child: Text('Welcome to the Home Page!')),
      ),
    );
  }

}