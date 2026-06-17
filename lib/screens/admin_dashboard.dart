import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import 'login.dart';
import 'add_police_station_screen.dart';
import '../widgets/safety_logo.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _cases = [];
  List<dynamic> _police = [];
  List<dynamic> _users = [];
  String _caseFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final statsRes = await ApiService.getAdminStats();
      final casesRes = await ApiService.getAllCases();
      final policeRes = await ApiService.getAllPolice();
      final usersRes = await ApiService.getAllUsers();

      if (mounted) {
        setState(() {
          _stats = statsRes['stats'] ?? {};
          _cases = casesRes['cases'] ?? [];
          _police = policeRes['police'] ?? [];
          _users = usersRes['users'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error loading admin data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FA),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF7B1FA2)))
        : Column(
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
                        "Admin Console", 
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadData,
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildOverview(),
                    _buildCasesList(),
                    _buildPoliceList(),
                    _buildUsersList(),
                  ],
                ),
              ),
            ],
          ),
      floatingActionButton: _selectedIndex == 2 
        ? FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPoliceStationScreen()));
              if (result == true) _loadData();
            },
            backgroundColor: const Color(0xFF7B1FA2),
            icon: const Icon(Icons.add_location_alt, color: Colors.white),
            label: const Text("Add Station", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF7B1FA2),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
            BottomNavigationBarItem(icon: Icon(Icons.report_problem_rounded), label: 'Cases'),
            BottomNavigationBarItem(icon: Icon(Icons.local_police_rounded), label: 'Police'),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Users'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("System Overview", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard("Total Users", _stats['total_users']?.toString() ?? "0", Icons.people, Colors.blue, () {}),
              _buildStatCard("Total Police", _stats['total_police']?.toString() ?? "0", Icons.local_police, Colors.green, () {}),
              _buildStatCard("Pending", _stats['pending_cases']?.toString() ?? "0", Icons.timer, Colors.orange, 
                () => setState(() => _caseFilter = _caseFilter == 'Pending' ? 'All' : 'Pending')),
              _buildStatCard("Investigating", _stats['investigating_cases']?.toString() ?? "0", Icons.search, Colors.purple,
                () => setState(() => _caseFilter = _caseFilter == 'Investigating' ? 'All' : 'Investigating')),
              _buildStatCard("Solved", _stats['solved_cases']?.toString() ?? "0", Icons.check_circle, Colors.teal,
                () => setState(() => _caseFilter = _caseFilter == 'Solved' ? 'All' : 'Solved')),
            ],
          ),
          const SizedBox(height: 30),
          Text(_caseFilter == 'All' ? "Recent Cases" : "$_caseFilter Cases", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
          const SizedBox(height: 10),
          ...(_cases.where((c) {
            if (_caseFilter == 'All') return true;
            return c['status'] == _caseFilter;
          }).take(5).map((c) => FadeInLeft(child: _buildCaseItem(c))).toList()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    bool isSelected = _caseFilter == title;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.1) : const Color(0xFF4A148C).withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
            Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    final filtered = _cases.where((c) {
      if (_caseFilter == 'All') return true;
      return c['status'] == _caseFilter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: filtered.length,
      itemBuilder: (context, index) => FadeInUp(
        delay: Duration(milliseconds: index * 50),
        child: _buildCaseItem(filtered[index]),
      ),
    );
  }

  Widget _buildCaseItem(Map<String, dynamic> caseData) {
    bool isPending = caseData['status'] == 'Pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(caseData['description'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Reporter: ${caseData['user_name']}", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
            Text("Location: ${caseData['location'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isPending ? Colors.orange : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            caseData['status'],
            style: GoogleFonts.poppins(color: isPending ? Colors.orange : Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPoliceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _police.length,
      itemBuilder: (context, index) {
        final p = _police[index];
        bool isVerified = p['is_verified'] == "1";
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.1),
                child: const Icon(Icons.local_police, color: Color(0xFF7B1FA2)),
              ),
              title: Text(p['fullname'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF4A148C))),
              subtitle: Text("Badge: ${p['badge_number'] ?? 'N/A'}\nEmail: ${p['email']}", style: GoogleFonts.poppins(fontSize: 12)),
              trailing: isVerified 
                ? const Icon(Icons.verified, color: Colors.blue, size: 20)
                : const Icon(Icons.pending, color: Colors.orange, size: 20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final u = _users[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF7B1FA2)),
              ),
              title: Text(u['fullname'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF4A148C))),
              subtitle: Text("Phone: ${u['phone']}\nEmail: ${u['email']}", style: GoogleFonts.poppins(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}

