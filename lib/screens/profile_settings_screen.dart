import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:upnepa/constants/app_colors.dart';
import '../services/auth_services.dart';
import 'package:http/http.dart' as http;

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final AuthService _authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        firstNameController.text = userData['first_name'] ?? '';
        lastNameController.text = userData['last_name'] ?? '';
        phoneController.text =
            userData['phone']?.toString().replaceAll('.0', '') ?? '';
        emailController.text = userData['email'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString == null) throw Exception("User not logged in");

      final userData = jsonDecode(userDataString);
      final email = userData['email'];
      if (email == null) throw Exception("Email missing");

      final updatedData = {
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(), // send email for identification
      };

      final url = Uri.parse("${_authService.baseUrl}/update_profile.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      final data = jsonDecode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? "Failed to update profile");
      }

      // Update SharedPreferences
      await _authService.updateStoredUserData(data['user']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile settings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFEFFAF2),
                        child: Icon(
                          Icons.person,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("First Name"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: firstNameController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter first name'
                          : null,
                      decoration: _readOnlyFieldDecoration(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Last Name"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: lastNameController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter last name'
                          : null,
                      decoration: _readOnlyFieldDecoration(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Phone Number"),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            initialValue: "+234",
                            readOnly: true,
                            decoration: _readOnlyFieldDecoration(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          flex: 5,
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter phone number';
                              } else if (value.length != 11) {
                                return 'Phone must be 11 digits';
                              }
                              return null;
                            },
                            decoration: _readOnlyFieldDecoration(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                        Text(
                          "Update phone number",
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Email"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter email address';
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: _readOnlyFieldDecoration(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                        Text(
                          "Update email",
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _readOnlyFieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
