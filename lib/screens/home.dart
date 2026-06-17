import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import 'login.dart';
import 'contacts_screen.dart';
import 'area_safety_screen.dart';
import 'safety_tips_screen.dart';
import 'register_case_screen.dart';
import '../widgets/safety_logo.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<dynamic> _cases = [];
  List<dynamic> _contacts = [];
  bool _isLoading = true;
  String _userName = "User";
  int _sosCountdown = 0;
  Timer? _sosTimer;
  String _currentLocation = "Chalakudy"; // Updated default location

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCases();
    _fetchContacts();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('fullname') ?? "User";
    });
  }

  void _fetchCases() async {
    try {
      var res = await ApiService.getCases(widget.userId);
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() => _cases = res['cases'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching cases: $e");
    }
    setState(() => _isLoading = false);
  }

  void _fetchContacts() async {
    try {
      var res = await ApiService.getContacts(widget.userId);
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() => _contacts = res['contacts'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
    }
  }

  void _startSosCountdown() {
    if (_sosCountdown > 0) return;
    setState(() { _sosCountdown = 5; });
    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sosCountdown > 1) {
        setState(() { _sosCountdown--; });
      } else {
        _cancelSosTimer();
        _performSosAction();
      }
    });
  }

  void _cancelSos() {
    _cancelSosTimer();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Signal Cancelled'), backgroundColor: Colors.blueGrey, behavior: SnackBarBehavior.floating));
  }

  void _cancelSosTimer() {
    _sosTimer?.cancel();
    _sosTimer = null;
    setState(() { _sosCountdown = 0; });
  }

  void _performSosAction() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw Exception('Location permission missing');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      await ApiService.sendSos(widget.userId, position.latitude, position.longitude);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Signal Sent!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    } catch (e) {
      await ApiService.sendSos(widget.userId, 0.0, 0.0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Sent (Manual Mode)'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Convex Header
            ClipPath(
              clipper: ConvexClipper(),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SafetyLogo(size: 50, color: Colors.white),
                        Text(
                          "Kaval",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: _logout,
                          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Welcome Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: Text(
                      "Hello, $_userName!",
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: RichText(
                      text: TextSpan(
                        text: "You are currently: ",
                        style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
                        children: [
                          TextSpan(text: "Safe in $_currentLocation", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SOS Interactive Area
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse Waves
                  if (_sosCountdown == 0) ...[
                    _buildPulseWave(220, 0),
                    _buildPulseWave(260, 400),
                    _buildPulseWave(300, 800),
                  ],
                  Column(
                    children: [
                      Text("Tap for Emergency", style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _sosCountdown > 0 ? null : _startSosCountdown,
                        child: Container(
                          height: 140, width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFE53935)]),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _sosCountdown > 0 ? "$_sosCountdown" : "SOS",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_sosCountdown > 0) ...[
                        Text("Countdown: 0$_sosCountdown s", style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _cancelSos,
                          icon: const Icon(Icons.cancel, color: Colors.blueGrey, size: 16),
                          label: Text("Cancel", style: GoogleFonts.poppins(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                        ),
                      ] else ...[
                        Text("Countdown: 00s", style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Grid Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildToolCard("Emergency Contacts", Icons.people_rounded, "${_contacts.isEmpty ? '0' : _contacts.length} numbers", "Trusted Circle", () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => ContactsScreen(userId: widget.userId)));
                    _fetchContacts();
                  }),
                  _buildToolCard("Report Case", Icons.report_problem_rounded, null, "File an Incident", () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterCaseScreen(userId: widget.userId)));
                    if (result == true) _fetchCases();
                  }),
                  _buildToolCard("Live Location", Icons.my_location_rounded, null, "Active Now", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AreaSafetyScreen()));
                  }),
                  _buildToolCard("Kaval Bot", Icons.auto_awesome_rounded, null, "AI Assistant", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyTipsScreen()));
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Horizontal Recent Alerts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Alerts", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF6A1B9A).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text("${_cases.length}", style: GoogleFonts.poppins(color: const Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (_cases.isNotEmpty)
                    ..._cases.take(3).map((c) => _buildHorizontalCard(
                      "Your Report", 
                      c['description'] ?? "No Details", 
                      Colors.redAccent, 
                      () => _showCaseDetail(c)
                    ))
                  else
                    _buildHorizontalCard("No Alerts", "Your system is clear", Colors.green, () {}),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  void _showCaseDetail(dynamic c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Alert Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: ${c['description']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("Status: ${c['status'] ?? 'Active'}", style: GoogleFonts.poppins(color: Colors.redAccent)),
            const SizedBox(height: 12),
            Text("Recommended Action: Stay away from the reported area and contact authorities if you have information.", style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  Widget _buildPulseWave(double size, int delay) {
    return FadeIn(
      delay: Duration(milliseconds: delay),
      child: ElasticIn(
        child: Container(
          height: size, width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.1), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(String title, IconData icon, String? badge, String subtitle, VoidCallback onTap) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: const Color(0xFF6A1B9A), size: 24),
                    const SizedBox(height: 8),
                    Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black45)),
                  ],
                ),
              ),
              if (badge != null)
                Positioned(
                  right: 8, top: 8,
                  child: Column(
                    children: [
                      Text(badge.split(' ')[0], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A))),
                      Text(badge.split(' ').length > 1 ? badge.split(' ')[1] : "", style: GoogleFonts.poppins(fontSize: 8, color: Colors.black54)),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(String title, String subtitle, Color color, VoidCallback onTap) {
    return FadeInRight(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.info_outline, color: color, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


