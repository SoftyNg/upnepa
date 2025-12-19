import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';
import 'profile_settings_screen.dart'; // ✅ Profile settings
import 'saved_meters_screen.dart'; // ✅ Saved Meters
import 'update_password_screen.dart'; // ✅ Update Password
import 'help_support_screen.dart'; // ✅ Help & Support
import 'home_screen.dart'; // ✅ Redirect target after logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String? token; // ✅ store token

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final storedToken = prefs.getString('user_token'); // ✅ fetch token

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        setState(() {
          firstName = userData['first_name'] ?? '';
          lastName = userData['last_name'] ?? '';
          email = userData['email'] ?? '';
          phoneNumber = userData['phone'] ?? '';
          token = storedToken; // ✅ save token in state
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();

      if (!mounted) return;

      // ✅ Redirect to HomeScreen instead of /login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to logout please try again")),
      );
    }
  }

  // ✅ Logout confirmation modal
  void _showLogoutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title + close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Log out",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                "Are you sure you want to log out of the app?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "No, cancel",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _logout();
                  },
                  child: const Text(
                    "Yes, log out",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBgColor ?? Colors.green.shade50,
        child: Icon(icon, color: iconColor ?? Colors.green),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Profile Box with navigation to settings
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE7F8EC),
                        child: Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text(
                        firstName.isNotEmpty || lastName.isNotEmpty
                            ? '$firstName $lastName'
                            : 'User',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                          phoneNumber.isNotEmpty ? phoneNumber : 'No phone'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                      // ✅ Navigate to ProfileSettingsScreen on tap
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "General",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // ✅ Navigate to SavedMetersScreen
                  buildMenuItem(
                    icon: Icons.save,
                    title: "Saved meters",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedMetersScreen(),
                        ),
                      );
                    },
                  ),

                  // ✅ Navigate to UpdatePasswordScreen with real token
                  buildMenuItem(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdatePasswordScreen(
                            email: email,
                            token: token ?? '',
                          ),
                        ),
                      );
                    },
                  ),

                  // ✅ Navigate to HelpSupportScreen
                  buildMenuItem(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),

                  // ✅ Logout (opens modal now)
                  buildMenuItem(
                    icon: Icons.logout,
                    title: "Logout",
                    iconBgColor: Colors.red.shade50,
                    iconColor: Colors.red,
                    onTap: () => _showLogoutModal(context),
                  ),
                ],
              ),
      ),
    );
  }
}
