import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TIP: For Chrome (Flutter Web), use "http://localhost/backend"
  // TIP: For Android Emulator, use "http://10.0.2.2/backend"
  // TIP: For Physical Device, use your computer's IP (e.g., "http://192.168.x.x/backend")
  static const String baseUrl = "http://192.168.0.108/backend";


  static Future<Map<String, dynamic>> login(String email, String password) async {
    print("Attempting login to: $baseUrl/login.php");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      print("Server Response Status: ${response.statusCode}");
      print("Server Response Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Login Error: $e");
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> register(String fullname, String email, String phone, String password, {String role = 'user', String? badgeNumber}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "email": email,
        "phone": phone,
        "password": password,
        "role": role,
        "badge_number": badgeNumber
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addContact(int userId, String name, String phone, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_contact.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "name": name, "phone": phone, "email": email}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteContact(int userId, int contactId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_contact.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "contact_id": contactId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getContacts(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_contacts.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendSos(int userId, double lat, double lon) async {
    final response = await http.post(
        Uri.parse('$baseUrl/sos.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "latitude": lat, "longitude": lon})
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCases(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_cases.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_login.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin_stats.php'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_all_users.php'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAllPolice() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_all_police.php'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAllCases() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_all_cases.php'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addPoliceStation(String name, String email, String password, double lat, double lon, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_police_station.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": name,
        "email": email,
        "password": password,
        "latitude": lat,
        "longitude": lon,
        "phone": phone
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addCase(int userId, String description, String location, {double? lat, double? lon}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_case.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "description": description,
        "location": location,
        "latitude": lat,
        "longitude": lon
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCaseStatus(int caseId, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_case_status.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "case_id": caseId,
        "status": status
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> askSafetyAi(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/safety_chat.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getPoliceStats() async {
    final response = await http.get(Uri.parse('$baseUrl/get_police_stats.php'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAreaSafety(double lat, double lon) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_area_safety.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"latitude": lat, "longitude": lon}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify_email.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend_code.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }
}
