import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';

class AddPoliceStationScreen extends StatefulWidget {
  const AddPoliceStationScreen({Key? key}) : super(key: key);
  @override
  _AddPoliceStationScreenState createState() => _AddPoliceStationScreenState();
}

class _AddPoliceStationScreenState extends State<AddPoliceStationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  bool _isLoading = false;
  String _completePhoneNumber = "";

  void _addStation() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || _latController.text.isEmpty || 
        _lonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all required fields'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.addPoliceStation(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        double.parse(_latController.text),
        double.parse(_lonController.text),
        _completePhoneNumber.isEmpty ? _phoneController.text : _completePhoneNumber,
      );

      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message']), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
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
      backgroundColor: const Color(0xFFF8F0FA),
      appBar: AppBar(
        title: Text("Add Police Station", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FadeInDown(child: _buildField("Station Name", _nameController, Icons.local_police_rounded)),
            const SizedBox(height: 16),
            FadeInDown(delay: const Duration(milliseconds: 100), child: _buildField("Email (Login Username)", _emailController, Icons.email_rounded)),
            const SizedBox(height: 16),
            FadeInDown(delay: const Duration(milliseconds: 200), child: _buildField("Password", _passwordController, Icons.lock_rounded, isPassword: true)),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: IntlPhoneField(
                  controller: _phoneController,
                  initialCountryCode: 'IN',
                  style: GoogleFonts.poppins(color: const Color(0xFF4A148C)),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF7B1FA2)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF7B1FA2))),
                  ),
                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(child: _buildField("Latitude", _latController, Icons.location_on_rounded, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Longitude", _lonController, Icons.location_on_rounded, keyboardType: TextInputType.number)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: _isLoading ? null : _addStation,
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
                          "REGISTER POLICE STATION",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: const Color(0xFF4A148C)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF7B1FA2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF7B1FA2))),
        ),
      ),
    );
  }
}

