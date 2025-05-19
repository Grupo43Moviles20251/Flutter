import 'dart:io';
import 'package:flutter/material.dart';
import 'package:first_app/Dtos/user_dto.dart';
import 'package:first_app/Widgets/custom_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../ViewModels/user_viewmodel.dart';
import '../Services/connection_helper.dart';

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
  bool _hasInternetConnection = true;
  late ConnectivityService _connectivityService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final int _minAge = 13;
  final int _maxAge = 120;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _emailController = TextEditingController(text: widget.userData.email);
    _addressController = TextEditingController(text: widget.userData.address ?? '');

    // Initialize birthday controller and selected date
    if (widget.userData.birthday != null && widget.userData.birthday!.isNotEmpty) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.userData.birthday!);
        _birthdayController = TextEditingController(
          text: DateFormat('dd/MM/yyyy').format(_selectedDate!),
        );
      } catch (e) {
        _birthdayController = TextEditingController(text: widget.userData.birthday ?? '');
      }
    } else {
      _birthdayController = TextEditingController();
    }

    _imageUrl = widget.userData.photoUrl;
    _connectivityService = ConnectivityService();

    _checkInternetConnection();
    _connectivityService.connectivityStream.listen((result) {
      _checkInternetConnection();
    });
  }

  Future<void> _checkInternetConnection() async {
    final isConnected = await _connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _hasInternetConnection = isConnected;
      });
    }
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
    if (!_hasInternetConnection) {
      _showNoInternetMessage();
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showNoInternetMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay conexión a internet. Conéctate para realizar esta acción.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_hasInternetConnection) {
      _showNoInternetMessage();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = await widget.viewModel.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        birthday: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
        profileImage: _imageFile,
        existingImageUrl: _imageUrl,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? now.subtract(Duration(days: _minAge * 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(Duration(days: _maxAge * 365)),
      lastDate: now.subtract(Duration(days: _minAge * 365)),
      helpText: 'Select your birthday',
      errorFormatText: 'Enter a valid date',
      errorInvalidText: 'Enter a date between the range',
      fieldLabelText: 'Birthday',
      fieldHintText: 'Day/Month/Year',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                _buildTextField(_nameController, 'Name', Icons.person),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField(
                    _addressController, 'Direction', Icons.location_on),
                const SizedBox(height: 20),
                _buildTextField(_birthdayController, 'Birthday',
                    Icons.cake,
                    isDate: true),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_isLoading || !_hasInternetConnection)
                        ? null
                        : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasInternetConnection
                          ? const Color(0xFF2A9D8F)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: !_hasInternetConnection
                        ? const Icon(Icons.wifi_off)
                        : const Icon(Icons.save),
                    label: !_hasInternetConnection
                        ? const Text(
                      'No Conexion',
                      style: TextStyle(fontSize: 18),
                    )
                        : const Text(
                      'Save',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                if (!_hasInternetConnection) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Conéctat to internet to save changes',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
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
        suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
      ),
      readOnly: isDate,
      maxLength: label == 'Name' || label == 'Email'
          ? 50
          : label == 'Direction'
          ? 50
          : null,
      validator: (value) {
        if (label == 'Nombre' && (value == null || value.isEmpty)) {
          return 'Please enter your name';
        }
        if (label == 'Email' && (value == null || value.isEmpty)) {
          return 'Please enter your email';
        }
        if (label == 'Email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Enter a valid email';
        }
        if (label == 'Birthday' && value != null && value.isNotEmpty) {
          try {
            final date = DateFormat('dd/MM/yyyy').parse(value);
            final now = DateTime.now();
            final minDate = DateTime(now.year - _maxAge, now.month, now.day);
            final maxDate = DateTime(now.year - _minAge, now.month, now.day);

            if (date.isBefore(minDate) ){
            return 'Maximum Age: $_maxAge años';
            }
            if (date.isAfter(maxDate)) {
        return 'You should be atleast $_minAge years old';
        }
        } catch (e) {
        return 'Invañid Format (DD/MM/YYYY)';
        }
      }
        return null;
      },
      onTap: isDate ? () => _selectDate(context) : null,
    );
  }
}