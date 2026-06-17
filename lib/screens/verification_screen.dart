import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String? initialCode; // For testing/convenience

  const VerificationScreen({Key? key, required this.email, this.initialCode}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    if (widget.initialCode != null && widget.initialCode!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = widget.initialCode![i];
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _start = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() => _start--);
      }
    });
  }

  void _resendCode() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);
    try {
      var res = await ApiService.resendOtp(widget.email);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message']),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        _startTimer();
      } else {
        setState(() => _error = res['message']);
      }
    } catch (e) {
      setState(() => _error = "Connection Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verify() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      setState(() => _error = "Please enter all 6 digits");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var res = await ApiService.verifyEmail(widget.email, otp);
      if (!mounted) return;
      if (res['success'] == true) {
        // Auto-login after successful verification
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', res['user_id']);
          await prefs.setString('role', res['role'] ?? 'user');
          await prefs.setString('fullname', res['fullname'] ?? 'User');
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email verified! Logging you directly in...'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userId: res['user_id'])),
            (route) => false,
          );
        } catch (e) {
          // Fallback to login if prefs fail
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        setState(() => _error = res['message']);
      }
    } catch (e) {
      setState(() => _error = "Connection Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Solid background
          Container(
            color: const Color(0xFFF3E5F5),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A148C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFF4A148C)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Verify Email",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A148C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We've sent a 6-digit code to",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF4A148C).withOpacity(0.6),
                      ),
                    ),
                    Text(
                      widget.email,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(6, (index) => _buildOtpNode(index)),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: _isLoading ? null : _verify,
                            child: Container(
                              height: 55,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: _isLoading 
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      "VERIFY",
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
                    
                    const SizedBox(height: 24),
                    // Resend Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4A148C).withOpacity(0.6)),
                        ),
                        TextButton(
                          onPressed: _canResend ? _resendCode : null,
                          child: Text(
                            _canResend ? "Resend" : "Resend in $_start s",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _canResend ? const Color(0xFF7B1FA2) : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Change Email",
                        style: GoogleFonts.poppins(color: const Color(0xFF7B1FA2), fontWeight: FontWeight.bold),
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

  Widget _buildOtpNode(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C)),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A148C), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2.5),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            FocusScope.of(context).unfocus();
            _verify();
          }
        },
      ),
    );
  }
}
