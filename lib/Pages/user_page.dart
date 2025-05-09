import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_app/Repositories/user_repository.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:first_app/ViewModels/user_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/Widgets/profile_image_widget.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  UserDTO? userData;
  bool isLoading = true;
  bool isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final ConnectivityService _connectivityService = ConnectivityService();
  final _userViewModel = UserViewModel(UserRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _initConnectivityListener() {
    // Check initial connectivity status
    _connectivityService.isConnected().then((connected) {
      if (mounted) {
        setState(() {
          isOnline = connected;
        });
      }
    });

    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((results) async {
      final bool wasOffline = !isOnline;
      final bool isNowOnline = await _connectivityService.isConnected();

      if (mounted) {
        setState(() {
          isOnline = isNowOnline;
        });

        // Show connectivity status snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNowOnline ? 'Internet connection restored' : 'No internet connection'),
            duration: Duration(seconds: 3),
            backgroundColor: isNowOnline ? Colors.green : Colors.red,
          ),
        );

        // Reload data if connection was restored
        if (wasOffline && isNowOnline) {
          _reloadUserData();
        }
      }
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('userData');

    if (mounted) {
      setState(() {
        if (userJson != null) {
          userData = UserDTO.fromJson(json.decode(userJson));
        }
        isLoading = false;
      });
    }
  }

  Future<void> _reloadUserData() async {
    try {
      if (await _connectivityService.isConnected()) {
        setState(() => isLoading = true);
        await _loadUserData();
      }
    } catch (e) {
      print('Error reloading user data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: PopScope(
        canPop: false,
        child: Scaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _reloadUserData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  // Profile Avatar
                  ProfileImageWithLRUCache(
                    imageUrl: userData?.photoUrl,
                    radius: 60,
                    isOnline: isOnline,
                  ),
                  SizedBox(height: 20),

                  // User Name
                  Text(
                    userData?.name ?? 'No name provided',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),

                  // User Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Email
                          _buildInfoRow(Icons.email, 'Email', userData?.email ?? 'No email'),
                          Divider(height: 30),

                          // Address
                          _buildInfoRow(Icons.location_on, 'Address',
                              userData?.address ?? 'No address provided'),
                          Divider(height: 30),

                          // Birthday
                          _buildInfoRow(Icons.cake, 'Birthday',
                              userData?.birthday ?? 'Not specified'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit Button
                      ElevatedButton(
                        onPressed: () async {
                          if (!isOnline) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No internet connection. Try again when you\'re back online.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String? userJson = prefs.getString('userData');
                          if (userJson != null) {
                            final updatedUser = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  userData: UserDTO.fromJson(json.decode(userJson)),
                                  viewModel: _userViewModel,
                                ),
                              ),
                            );

                            if (updatedUser != null && mounted) {
                              setState(() => userData = updatedUser);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A9D8F),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Sign Out Button
                      ElevatedButton(
                        onPressed: () async {
                          if (!isOnline) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No internet connection. Try again when you\'re back online.'),
                                  duration: Duration(seconds: 3),
                                ));
                                return;
                            }
                                await _logout();
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      selectedIndex: 0,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF2A9D8F)),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("userData");
      await prefs.remove("isLoggedIn");

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
          settings: RouteSettings(name: "LoginPage"),
        ),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}