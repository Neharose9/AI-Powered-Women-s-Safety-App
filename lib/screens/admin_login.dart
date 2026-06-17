import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../widgets/safety_logo.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  void _login() async {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty ? 'Enter admin email' : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Enter password' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      var res = await ApiService.adminLogin(_emailController.text, _passwordController.text);
      if (!mounted) return;
      
      if (res['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('admin_id', res['user_id']);
        await prefs.setString('role', 'admin');
        
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? 'Login Failed'), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
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
          // Lavender Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8F0FA), Color(0xFFE8D7F1), Color(0xFFF3E5F5)],
              ),
            ),
          ),
          
          // Background Blobs
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FadeInLeft(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A148C), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
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
                    FadeInDown(
                      child: Column(
                        children: [
                          const SafetyLogo(size: 100, color: Color(0xFF4A148C)),
                          const SizedBox(height: 24),
                          Text(
                            "ADMIN PORTAL",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A148C),
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            "System Administration & Oversight",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF4A148C).withOpacity(0.6),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    
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
                                    label: 'Administrator Email',
                                    icon: Icons.alternate_email,
                                    errorText: _emailError,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Access Key / Password',
                                    icon: Icons.vpn_key_outlined,
                                    isPassword: true,
                                    errorText: _passwordError,
                                  ),
                                  const SizedBox(height: 30),
                                  
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
                                              "AUTHORIZE ACCESS",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      "Return to Primary Login",
                                      style: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.5), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5).withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: errorText != null ? Colors.redAccent : const Color(0xFFE1BEE7)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Color(0xFF4A148C)),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.4), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF7B1FA2).withOpacity(0.7), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
          ),
      ],
    );
  }
}

