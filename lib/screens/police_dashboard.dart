import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import '../widgets/safety_logo.dart';
import 'login.dart';

class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({Key? key}) : super(key: key);
  @override
  _PoliceDashboardState createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  List<dynamic> _cases = [];
  Map<String, dynamic> _stats = {'active': 0, 'solved': 0, 'pending': 0};
  bool _isLoading = true;
  String _activeFilter = 'Active'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchCases();
  }

  Future<void> _fetchCases() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await ApiService.getPoliceStats();
      final casesRes = await ApiService.getAllCases();
      
      if (!mounted) return;
      
      setState(() {
        if (statsRes['success'] == true) {
          _stats = statsRes['stats'];
        }
        if (casesRes['success'] == true) {
          _cases = casesRes['cases'] ?? [];
        }
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
    setState(() => _isLoading = false);
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
      body: Column(
        children: [
          // Custom Branded Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SafetyLogo(size: 60, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Police HQ", 
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
                IconButton(onPressed: _fetchCases, icon: const Icon(Icons.refresh, color: Colors.white)),
                IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.white)),
              ],
            ),
          ),
          _buildStats(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7B1FA2)))
              : () {
                  final filteredCases = _cases.where((c) {
                    if (_activeFilter == 'Resolved') return c['status'] == 'Solved';
                    if (_activeFilter == 'Pending') return c['status'] == 'Pending';
                    if (_activeFilter == 'Active') return c['status'] == 'Pending' || c['status'] == 'Investigating';
                    return true;
                  }).toList();

                  return filteredCases.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: filteredCases.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          var c = filteredCases[index];
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: _buildCaseCard(c),
                          );
                        },
                      );
                }(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            "Active Alerts", 
            _stats['active'].toString(), 
            Colors.white,
            () => setState(() => _activeFilter = _activeFilter == 'Active' ? 'All' : 'Active'),
            _activeFilter == 'Active'
          ),
          _statItem(
            "Resolved", 
            _stats['solved'].toString(), 
            Colors.white.withOpacity(0.9),
            () => setState(() => _activeFilter = _activeFilter == 'Resolved' ? 'All' : 'Resolved'),
            _activeFilter == 'Resolved'
          ),
          _statItem(
            "Pending", 
            _stats['pending'].toString(), 
            Colors.white.withOpacity(0.8),
            () => setState(() => _activeFilter = _activeFilter == 'Pending' ? 'All' : 'Pending'),
            _activeFilter == 'Pending'
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color, VoidCallback onTap, bool isSelected) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No location URL available")));
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
    }
  }

  Widget _buildCaseCard(dynamic c) {
    bool isPending = c['status'] == 'Pending';
    bool isInvestigating = c['status'] == 'Investigating';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A148C).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.red.withOpacity(0.1) : (isInvestigating ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
          child: Icon(
            isPending ? Icons.warning_amber_rounded : (isInvestigating ? Icons.search : Icons.check_circle_outline), 
            color: isPending ? Colors.red : (isInvestigating ? Colors.blue : Colors.green), 
            size: 20
          ),
        ),
        title: Text(c['description'] ?? "No Description", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF4A148C))),
        subtitle: Text("Location: ${c['location'] ?? 'Unknown'}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isPending ? Colors.red : (isInvestigating ? Colors.blue : Colors.green)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            c['status'] ?? "Pending", 
            style: TextStyle(
              color: isPending ? Colors.red : (isInvestigating ? Colors.blue : Colors.green), 
              fontWeight: FontWeight.bold, 
              fontSize: 10
            )
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending)
                      ElevatedButton(
                        onPressed: () => _updateStatus(c['id'], 'Investigating'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B1FA2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Investigate", style: TextStyle(color: Colors.white)),
                      ),
                    if (isInvestigating)
                      ElevatedButton(
                        onPressed: () => _updateStatus(c['id'], 'Solved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Solve Case", style: TextStyle(color: Colors.white)),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _launchUrl(c['location']), 
                      icon: const Icon(Icons.map, color: Color(0xFF7B1FA2)), 
                      label: Text("View Map", style: TextStyle(color: const Color(0xFF7B1FA2))),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _updateStatus(var caseId, String status) async {
    try {
      final res = await ApiService.updateCaseStatus(int.parse(caseId.toString()), status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message']),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4A148C),
      ));
      _fetchCases();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: const Color(0xFF7B1FA2).withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No Active Alerts", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

