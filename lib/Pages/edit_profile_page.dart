// edit_profile_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:image_picker/image_picker.dart';

import '../ViewModels/user_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  final UserDTO userData;
  final UserViewModel viewModel;

  const EditProfilePage({
    super.key,
    required this.userData,
    required this.viewModel,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _birthdayController;

  File? _imageFile;
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _emailController = TextEditingController(text: widget.userData.email);
    _addressController = TextEditingController(text: widget.userData.address ?? '');
    _birthdayController = TextEditingController(text: widget.userData.birthday ?? '');
    _imageUrl = widget.userData.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });


    try {

      final updatedUser = await widget.viewModel.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        birthday: _birthdayController.text.isNotEmpty ? _birthdayController.text : null,
        profileImage: _imageFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );

      Navigator.pop(context, updatedUser);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_imageUrl != null
                      ? NetworkImage(_imageUrl!)
                      : null) as ImageProvider?,
                  child: _imageFile == null && _imageUrl == null
                      ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[600],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_nameController, 'Nombre', Icons.person),
              const SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 20),
              _buildTextField(
                  _addressController, 'Dirección', Icons.location_on),
              const SizedBox(height: 20),
              _buildTextField(_birthdayController, 'Fecha de Nacimiento',
                  Icons.cake,
                  isDate: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A9D8F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      selectedIndex: 0,
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isDate = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onTap: isDate
          ? () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          controller.text = '${date.day}/${date.month}/${date.year}';
        }
      }
          : null,
    );
  }
}