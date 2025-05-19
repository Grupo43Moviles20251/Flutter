import 'package:first_app/Repositories/order_repository.dart';
import 'package:first_app/ViewModels/order_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_app/ViewModels/user_viewmodel.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:first_app/Widgets/profile_image_widget.dart';
import 'package:first_app/Services/connection_helper.dart';
import 'package:first_app/Repositories/user_repository.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import 'order_history_page.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserViewModel(
        UserRepository(),
        ConnectivityService(),
      ),
      child: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return CustomScaffold(
            body: PopScope(
              canPop: false,
              child: Scaffold(
                body: viewModel.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: viewModel.reloadUserData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        // Profile Avatar
                        ProfileImageWithLRUCache(
                          imageUrl: viewModel.userData?.photoUrl,
                          radius: 60,
                          isOnline: viewModel.isOnline,
                        ),
                        SizedBox(height: 20),

                        // User Name
                        Text(
                          viewModel.userData?.name ?? 'No name provided',
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
                                _buildInfoRow(Icons.email, 'Email',
                                    viewModel.userData?.email ?? 'No email'),
                                Divider(height: 30),

                                // Address
                                _buildInfoRow(Icons.location_on, 'Address',
                                    viewModel.userData?.address ?? 'No address provided'),
                                Divider(height: 30),

                                // Birthday
                                _buildInfoRow(Icons.cake, 'Birthday',
                                    viewModel.userData?.birthday ?? 'Not specified'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),


                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {

                              return Column(
                                children: [
                                  _buildActionButton(context, viewModel, Icons.history, 'View Order History', () {
                                    _navigateToOrderHistory(context, viewModel);
                                  }, color: Colors.blue),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildActionButton(context, viewModel, Icons.edit, 'Edit Profile', () {
                                        _navigateToEditProfile(context, viewModel);
                                      }, color: Color(0xFF2A9D8F)),
                                      _buildActionButton(context, viewModel, Icons.logout, 'Sign Out', () {
                                        _signOut(context, viewModel);
                                      }, color: Colors.red),
                                    ],
                                  ),
                                ],
                              );
                            } else {

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(context, viewModel, Icons.history, 'View Order History', () {
                                    _navigateToOrderHistory(context, viewModel);
                                  }, color: Colors.blue),
                                  _buildActionButton(context, viewModel, Icons.edit, 'Edit Profile', () {
                                    _navigateToEditProfile(context, viewModel);
                                  }, color: Color(0xFF2A9D8F)),
                                  _buildActionButton(context, viewModel, Icons.logout, 'Sign Out', () {
                                    _signOut(context, viewModel);
                                  }, color: Colors.red),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            selectedIndex: 0,
          );
        },
      ),
    );
  }


  Future<void> _navigateToOrderHistory(BuildContext context, UserViewModel viewModel) async {
    if (!viewModel.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection. Try again when you\'re back online.'),
          duration: Duration(seconds: 3),
        ));
        return;
      }
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderHistoryPage(
              orderViewModel: OrderViewModel(orderRepository: OrderRepositoryImpl())),
        ),
      );
    }

  Future<void> _navigateToEditProfile(BuildContext context, UserViewModel viewModel) async {
    if (!viewModel.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection. Try again when you\'re back online.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (viewModel.userData != null) {
      final updatedUser = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            userData: viewModel.userData!,
            viewModel: viewModel,
          ),
        ),
      );

      if (updatedUser != null) {
        viewModel.userData = updatedUser;
      }
    }
  }

  Future<void> _signOut(BuildContext context, UserViewModel viewModel) async {
    if (!viewModel.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No internet connection. Try again when you\'re back online.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      await viewModel.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
          settings: RouteSettings(name: "LoginPage"),
        ),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildActionButton(
      BuildContext context,
      UserViewModel viewModel,
      IconData icon,
      String label,
      VoidCallback onPressed, {
        required Color color,
      }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white), // Icono en blanco
      label: Text(
        label,
        style: TextStyle(color: Colors.white), // Texto en blanco
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
}