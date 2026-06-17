import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../widgets/safety_logo.dart';

class AreaSafetyScreen extends StatefulWidget {
  const AreaSafetyScreen({Key? key}) : super(key: key);

  @override
  State<AreaSafetyScreen> createState() => _AreaSafetyScreenState();
}

class _AreaSafetyScreenState extends State<AreaSafetyScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _safetyData;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkSafety();
  }

  Future<void> _checkSafety() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentPosition = position;
      final res = await ApiService.getAreaSafety(position.latitude, position.longitude);
      setState(() {
        _safetyData = res;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), behavior: SnackBarBehavior.floating));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = _safetyData?['status'] ?? "Unknown";
    String colorStr = _safetyData?['color'] ?? "green";
    
    Color themeColor = colorStr == 'red' 
        ? Colors.redAccent 
        : (colorStr == 'yellow' ? Colors.orangeAccent : Colors.teal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FA),
      appBar: AppBar(
        title: Text("Area Safety", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SafetyLogo(size: 30, color: Colors.white),
          ),
        ],
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF7B1FA2)),
                  const SizedBox(height: 20),
                  Text("Analyzing safety metrics...", style: GoogleFonts.poppins(color: const Color(0xFF4A148C))),
                ],
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: const Color(0xFF4A148C).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                _currentPosition?.latitude ?? 0.0,
                                _currentPosition?.longitude ?? 0.0,
                              ),
                              initialZoom: 14.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.yourapp.safetyapp',
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: LatLng(
                                      _currentPosition?.latitude ?? 0.0,
                                      _currentPosition?.longitude ?? 0.0,
                                    ),
                                    radius: 1200, 
                                    useRadiusInMeter: true,
                                    color: themeColor.withOpacity(0.15),
                                    borderColor: themeColor.withOpacity(0.5),
                                    borderStrokeWidth: 2,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      _currentPosition?.latitude ?? 0.0,
                                      _currentPosition?.longitude ?? 0.0,
                                    ),
                                    width: 80,
                                    height: 80,
                                    child: Icon(
                                      Icons.location_history_rounded,
                                      color: themeColor,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      child: Text(
                        _safetyData?['message'] ?? "No data available",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: const Color(0xFF4A148C), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: const Color(0xFF4A148C).withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            _buildStatRow("Live Reports", "${_safetyData?['live_incidents'] ?? 0}", Colors.orange),
                            const Divider(height: 30),
                            _buildStatRow("Historical Data", "${_safetyData?['historical_incidents'] ?? 0}", const Color(0xFF7B1FA2)),
                            const Divider(height: 30),
                            _buildStatRow("Safety Score", "${_safetyData?['safety_score'] ?? 0}", themeColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      child: GestureDetector(
                        onTap: _checkSafety,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  "RE-SCAN AREA",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: const Color(0xFF4A148C), fontWeight: FontWeight.w600)),
        Text(
          value,
          style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

