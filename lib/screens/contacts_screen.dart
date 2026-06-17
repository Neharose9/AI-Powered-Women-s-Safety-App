import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/api_service.dart';
import '../widgets/safety_logo.dart';

class ContactsScreen extends StatefulWidget {
  final int userId;
  const ContactsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() => _isLoading = true);
    try {
      var res = await ApiService.getContacts(widget.userId);
      if (res['success'] == true) {
        setState(() => _contacts = res['contacts'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteContact(int contactId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Contact", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
        content: Text("Are you sure you want to remove this guardian from your trusted circle?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                var res = await ApiService.deleteContact(widget.userId, contactId);
                if (res['success'] == true) {
                  _fetchContacts();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guardian removed"), backgroundColor: Colors.blueGrey, behavior: SnackBarBehavior.floating));
                  }
                } else {
                  setState(() => _isLoading = false);
                }
              } catch (e) {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Remove", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String completePhoneNumber = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Add Guardian", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController, 
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Full Name", 
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF7B1FA2)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                )
              ),
              const SizedBox(height: 15),
              IntlPhoneField(
                controller: phoneController,
                initialCountryCode: 'IN',
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7B1FA2))),
                ),
                onChanged: (phone) {
                  completePhoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController, 
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Email (Optional)", 
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFF7B1FA2)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                ), 
                keyboardType: TextInputType.emailAddress
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600))
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && (phoneController.text.isNotEmpty || completePhoneNumber.isNotEmpty)) {
                var res = await ApiService.addContact(
                  widget.userId, 
                  nameController.text, 
                  completePhoneNumber.isEmpty ? phoneController.text : completePhoneNumber, 
                  emailController.text
                );
                if (res['success'] == true) {
                  Navigator.pop(context);
                  _fetchContacts();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contact added!"), behavior: SnackBarBehavior.floating));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1FA2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Save Contact", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FA),
      appBar: AppBar(
        title: Text("Trusted Contacts", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7B1FA2)))
          : _contacts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    var c = _contacts[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF4A148C).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.1),
                            child: const Icon(Icons.person_rounded, color: Color(0xFF7B1FA2)),
                          ),
                          title: Text(c['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
                          subtitle: Text(c['phone'], style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _deleteContact(int.parse(c['id'].toString())),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        backgroundColor: const Color(0xFF7B1FA2),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text("ADD GUARDIAN", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: const Color(0xFF7B1FA2).withOpacity(0.15)),
          const SizedBox(height: 24),
          Text("No contacts added yet.", style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF4A148C), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text("Add trusted people who should be notified when you trigger an SOS alert.", 
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

