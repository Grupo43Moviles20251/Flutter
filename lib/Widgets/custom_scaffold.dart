import 'package:flutter/material.dart';
import 'package:first_app/Pages/home_page.dart';
import 'package:first_app/Pages/search_page.dart';
import 'package:first_app/Pages/favorites_page.dart';
import 'package:first_app/Pages/map_page.dart';
import 'package:first_app/Pages/user_page.dart';  // Importar la página del usuario

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;  // Aquí definimos el parámetro

  CustomScaffold({required this.body, required this.selectedIndex});  // Lo pasamos al constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Image.asset('assets/logo.png', height: 40),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black, size: 30),
            onPressed: () {
              // Navegar a la página de usuario
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => UserPage(),
                settings: RouteSettings(name: "UserPage"),
              ));
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF38677A),
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex, // Aquí usamos el selectedIndex para marcar el botón activo
        onTap: (index) {
          // Dependiendo del índice, navegamos a la página correspondiente
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(selectedIndex: 0),
                  settings: RouteSettings(name: "HomePage")
              ),

            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => FavoritesPage(selectedIndex: 1),
                  settings: RouteSettings(name: "FavoritesPage")
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPage(selectedIndex: 2),
                  settings: RouteSettings(name: "SearchPage")),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MapPage(selectedIndex: 3),
                  settings: RouteSettings(name: "MapPage")),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Restaurants",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
        ],
      ),
    );
  }
}
