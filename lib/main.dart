import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/police_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'widgets/safety_logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KavalApp());
}

class KavalApp extends StatelessWidget {
  const KavalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaval',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Elegant splash transition before querying logic
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final adminId = prefs.getInt('admin_id');
    final role = prefs.getString('role');

    if (!mounted) return;

    if (userId != null || (role == 'admin' && adminId != null)) {
      if (role == 'police') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PoliceDashboard()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        // Fallback or explicit Citizen login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(userId: userId ?? adminId!)));
      }
    } else {
      // Not logged in properly or fresh install
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFF4A148C)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZoomIn(
              duration: const Duration(milliseconds: 800),
              child: const SafetyLogo(size: 140, color: Colors.white),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Text(
                "Kaval",
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Text(
                "Secure • Empowered • Connected",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
