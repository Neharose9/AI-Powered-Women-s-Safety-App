import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/api_service.dart';
import '../widgets/safety_logo.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _nameError, _emailError, _phoneError, _passwordError;
  String _completePhoneNumber = "";

  void _register() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Please fill in this field' : null;
      _emailError = _emailController.text.trim().isEmpty 
          ? 'Please fill in this field' 
          : (!_emailController.text.trim().toLowerCase().endsWith('@gmail.com') 
              ? 'Only @gmail.com addresses are allowed' 
              : null);
      _phoneError = _phoneController.text.trim().isEmpty ? 'Please fill in this field' : null;
      _passwordError = _passwordController.text.trim().isEmpty ? 'Please fill in this field' : null;
    });

    if (_nameError != null || _emailError != null || _phoneError != null || _passwordError != null) return;
    
    setState(() => _isLoading = true);
    try {
      var res = await ApiService.register(
        _nameController.text,
        _emailController.text,
        _completePhoneNumber.isEmpty ? _phoneController.text : _completePhoneNumber,
        _passwordController.text,
        role: 'user',
        badgeNumber: null,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        String email = _emailController.text;
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration successful. Please verify your email.'), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message']), 
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
          // Dynamic Background (Matches Login)
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
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FadeInLeft(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A148C), size: 20),
                onPressed: () => Navigator.pop(context),
              ),
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
                            "Create Account",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A148C),
                            ),
                          ),
                          Text(
                            "Join Kaval to stay safe and connected",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF4A148C).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Glassmorphism Card
                    FadeInUp(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(28),
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
                                    controller: _nameController,
                                    label: 'Full Name',
                                    icon: Icons.person_outline,
                                    errorText: _nameError,
                                    onChanged: (v) => setState(() => _nameError = null),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    errorText: _emailError,
                                    onChanged: (v) => setState(() => _emailError = null),
                                  ),
                                  const SizedBox(height: 16),
                                  IntlPhoneField(
                                    controller: _phoneController,
                                    initialCountryCode: 'IN',
                                    style: const TextStyle(color: Color(0xFF4A148C), fontSize: 14),
                                    dropdownTextStyle: const TextStyle(color: Color(0xFF4A148C)),
                                    cursorColor: const Color(0xFF7B1FA2),
                                    dropdownIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7B1FA2)),
                                    decoration: InputDecoration(
                                      hintText: 'Phone Number',
                                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.4), fontSize: 13),
                                      prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF7B1FA2), size: 18),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: _phoneError != null ? Colors.redAccent : const Color(0xFFE1BEE7)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Color(0xFFE1BEE7)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Color(0xFF7B1FA2)),
                                      ),
                                      fillColor: const Color(0xFFF3E5F5).withOpacity(0.5),
                                      filled: true,
                                      errorText: _phoneError,
                                      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
                                      counterStyle: const TextStyle(color: Color(0xFF4A148C)),
                                    ),
                                    onChanged: (phone) {
                                      _completePhoneNumber = phone.completeNumber;
                                      setState(() => _phoneError = null);
                                    },
                                    onCountryChanged: (country) {
                                      // Optional: handle country change
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    errorText: _passwordError,
                                    onChanged: (v) => setState(() => _passwordError = null),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Gradient Register Button
                                  GestureDetector(
                                    onTap: _isLoading ? null : _register,
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
                                              "REGISTER",
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
                    const SizedBox(height: 20),
                    
                    // Back to Login
                    FadeInUp(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.7)),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: GoogleFonts.poppins(color: const Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
                              ),
                            ],
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
            style: const TextStyle(color: Color(0xFF4A148C), fontSize: 14),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.4), fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF7B1FA2).withOpacity(0.7), size: 18),
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
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
      ],
    );
  }
}
