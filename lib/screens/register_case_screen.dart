import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';

class RegisterCaseScreen extends StatefulWidget {
  final int userId;
  const RegisterCaseScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RegisterCaseScreenState createState() => _RegisterCaseScreenState();
}

class _RegisterCaseScreenState extends State<RegisterCaseScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  double? _lat;
  double? _lon;
  bool _isLoading = false;
  bool _isLocating = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _lat = position.latitude;
          _lon = position.longitude;
          _locationController.text = "GPS: ${_lat!.toStringAsFixed(4)}, ${_lon!.toStringAsFixed(4)}";
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location captured!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching location: $e")));
    }
    setState(() => _isLocating = false);
  }

  void _submitCase() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a description")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.addCase(
        widget.userId,
        _descriptionController.text,
        _locationController.text.isEmpty ? "Current Location" : _locationController.text,
        lat: _lat,
        lon: _lon,
      );

      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Case Registered Successfully!"),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['message']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submission Error: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FA),
      appBar: AppBar(
        title: Text("Report Incident", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                "Submit a Case",
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C)),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text(
                "Provide accurate details regarding the incident for faster response.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 30),
            
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: _buildTextField(
                controller: _descriptionController,
                label: "Incident Description",
                hint: "Describe what happened...",
                maxLines: 4,
                icon: Icons.description_rounded,
              ),
            ),
            const SizedBox(height: 20),
            
            FadeInLeft(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _locationController,
                      label: "Location",
                      hint: "Enter address or landmark",
                      icon: Icons.location_on_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 25),
                    child: IconButton(
                      onPressed: _isLocating ? null : _getCurrentLocation,
                      icon: _isLocating 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6A1B9A)))
                        : const Icon(Icons.my_location_rounded, color: Color(0xFF6A1B9A)),
                      tooltip: "Get Current Location",
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: const Color(0xFF6A1B9A).withOpacity(0.5),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("REGISTER CASE", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4A148C))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF6A1B9A).withOpacity(0.7), size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1)),
          ),
        ),
      ],
    );
  }
}
