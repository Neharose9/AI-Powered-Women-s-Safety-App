import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../widgets/safety_logo.dart';
import 'home.dart';
import 'register.dart';
import 'police_login.dart';
import 'admin_login.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  void _login() async {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty ? 'Please fill in this field' : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Please fill in this field' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      var res = await ApiService.login(_emailController.text, _passwordController.text);
      if (!mounted) return;
      if (res['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!mounted) return;
        await prefs.setInt('user_id', res['user_id']);
        await prefs.setString('role', res['role'] ?? 'user');
        await prefs.setString('fullname', res['fullname'] ?? 'User');
        
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(userId: res['user_id'])));
      } else {
        if (res['code'] == 'VERIFICATION_REQUIRED') {
          String email = res['email'] ?? _emailController.text;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['message']), 
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'VERIFY',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VerificationScreen(email: email)),
                );
              }
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['message']), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8F0FA), Color(0xFFE8D7F1), Color(0xFFF3E5F5)],
              ),
            ),
          ),
          // Animated Blobs
          Positioned(
            top: -100,
            right: -50,
            child: FadeInDown(
              duration: const Duration(seconds: 2),
              child: _buildBlob(250, const Color(0xFFCE93D8).withOpacity(0.3)),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: FadeInUp(
              duration: const Duration(seconds: 2),
              child: _buildBlob(300, const Color(0xFFE1BEE7).withOpacity(0.2)),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SafetyLogo(size: 100, color: Color(0xFF4A148C)),
                    const SizedBox(height: 20),
                    Text(
                      "Kaval",
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A148C),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "Secure • Empowered • Connected",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF4A148C).withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Glassmorphism Card
                    FadeInUp(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A148C).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    errorText: _emailError,
                                    onChanged: (v) => setState(() => _emailError = null),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    errorText: _passwordError,
                                    onChanged: (v) => setState(() => _passwordError = null),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Forgot Password?",
                                        style: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.6), fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Gradient Login Button
                                  GestureDetector(
                                    onTap: _isLoading ? null : _login,
                                    child: Container(
                                      height: 55,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF7B1FA2).withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: _isLoading 
                                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text(
                                              "LOGIN",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Register Link
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.7)),
                            children: [
                              TextSpan(
                                text: "Register Now",
                                style: GoogleFonts.poppins(color: const Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Police Login Access
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PoliceLoginScreen())),
                            icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                            label: const Text("Police Department Access"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7B1FA2),
                              side: const BorderSide(color: Color(0xFF7B1FA2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                            icon: const Icon(Icons.security_update_good_outlined, size: 18),
                            label: const Text("Admin Portal Access"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A148C).withOpacity(0.6),
                              side: BorderSide(color: const Color(0xFF4A148C).withOpacity(0.2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5).withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: errorText != null ? Colors.redAccent : const Color(0xFFE1BEE7)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFF4A148C)),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.4), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF7B1FA2).withOpacity(0.7), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
