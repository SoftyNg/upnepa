import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/register_model.dart';

class AuthService {
  // ✅ Change this to your backend API base URL
  final String baseUrl = "https://realestatearena.com.ng";

  // SharedPreferences keys
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userTokenKey = 'user_token';

  // ✅ Register user
  Future<void> registerWithEmail(RegisterModel user) async {
    final url = Uri.parse("$baseUrl/register.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": user.firstName,
        "last_name": user.lastName,
        "email": user.email,
        "phone": user.phone,
        "password": user.password,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }
  }

  // ✅ Login user (with email verification check in PHP) + SharedPreferences storage
  Future<Map<String, dynamic>> loginWithEmail(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/login.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }

    // ✅ Store user details in SharedPreferences
    await _saveUserToPreferences(data['user']);

    // Return user details
    return data['user'];
  }

  // ✅ Save user data to SharedPreferences
  Future<void> _saveUserToPreferences(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Store user data as JSON string
    await prefs.setString(_userDataKey, jsonEncode(userData));

    // Store login status
    await prefs.setBool(_isLoggedInKey, true);

    // Store token if it exists in user data
    if (userData.containsKey('token')) {
      await prefs.setString(_userTokenKey, userData['token']);
    }
  }

  // ✅ Get stored user data from SharedPreferences
  Future<Map<String, dynamic>?> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString != null) {
      return jsonDecode(userDataString);
    }

    return null;
  }

  // ✅ Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ✅ Get stored token
  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTokenKey);
  }

  // ✅ Update user data in SharedPreferences
  Future<void> updateStoredUserData(Map<String, dynamic> userData) async {
    await _saveUserToPreferences(userData);
  }

  // ✅ Forgot password (PHP endpoint should send reset link/email)
  Future<void> sendPasswordResetEmail(String email) async {
    final url = Uri.parse("$baseUrl/forgot_password.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }
  }

  // ✅ Sign out (Clear SharedPreferences)
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all stored user data
    await prefs.remove(_userDataKey);
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userTokenKey);
  }

  // ✅ Fetch user details using token (from users table in PHP backend)
  Future<Map<String, dynamic>> getUserDetails() async {
    final token = await getStoredToken();
    if (token == null) throw Exception("Token missing");

    final url = Uri.parse("$baseUrl/get_user.php");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);
    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }

    // ✅ Update stored user data with fresh data from server
    await _saveUserToPreferences(data['user']);

    return data['user'];
  }

  // ✅ Auto-login check (call this when app starts)
  Future<Map<String, dynamic>?> checkAutoLogin() async {
    if (await isLoggedIn()) {
      try {
        return await getUserDetails();
      } catch (e) {
        await signOut();
        return null;
      }
    }
    return null;
  }

  // ✅ Reset password with token (called from UpdatePasswordScreen)
  Future<void> resetPassword(
      String email, String token, String newPassword) async {
    final url = Uri.parse("$baseUrl/reset_password.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "token": token,
        "new_password": newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }
  }

  // ✅ Update profile
  Future<void> updateProfile(Map<String, String> updatedData) async {
    final token = await getStoredToken();
    if (token == null) throw Exception("Token missing");

    final url = Uri.parse("$baseUrl/update_profile.php");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updatedData),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['message']);
    }

    // Update stored user data
    await _saveUserToPreferences(data['user']);
  }
}
