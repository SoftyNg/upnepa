import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upnepa/constants/app_colors.dart';
import 'package:upnepa/widgets/app_logo_header.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerifying = false;
  bool _isResending = false;

  void _checkIfVerified() async {
    setState(() => _isVerifying = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        _showSnackBar("✅ Email verified!");

        // ✅ Redirect to LoginScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        _showSnackBar("❌ Email not verified yet. Please check your inbox.");
      }
    } catch (e) {
      _showSnackBar("⚠️ Error verifying email. Try again.", isError: true);
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      _showSnackBar("📧 Verification email resent!");
    } catch (e) {
      _showSnackBar("Failed to resend email. Try again.", isError: true);
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogoHeader(),
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify your email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'A verification email has been sent to:\n${widget.email}\n\nPlease click the link in the email to verify your account.',
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
              const SizedBox(height: 24),

              /// ✅ Check verification button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _checkIfVerified,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'I have verified my email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              /// 🔁 "Request new code" = resend email
              Row(
                children: [
                  const Text("Didn't see the email in your inbox? "),
                  GestureDetector(
                    onTap: _isResending ? null : _resendVerificationEmail,
                    child: Text(
                      _isResending ? "Sending..." : "Request new code",
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Optional: phone number verification
              GestureDetector(
                onTap: () {
                  // TODO: Handle alternative phone verification
                },
                child: const Text(
                  "Verify with phone number",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
