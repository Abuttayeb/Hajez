import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  static Map<String, String> get _headers => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  static Future<Map<String, dynamic>> register({required String name, required String email, required String phone, required String password, required String role}) async {
    final res = await http.post(Uri.parse('$BASE_URL/register'), headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'phone': phone, 'password': password, 'password_confirmation': password, 'role': role}));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await http.post(Uri.parse('$BASE_URL/login'), headers: _headers,
      body: jsonEncode({'email': email, 'password': password}));
    return jsonDecode(res.body);
  }

  static Future<void> saveSession(String token, String role, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString('token');
  static Future<String?> getRole() async => (await SharedPreferences.getInstance()).getString('role');
  static Future<Map<String, dynamic>?> getUser() async {
    final s = (await SharedPreferences.getInstance()).getString('user');
    return s != null ? jsonDecode(s) : null;
  }
  static Future<bool> isLoggedIn() async => (await getToken()) != null;
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); await prefs.remove('role'); await prefs.remove('user');
  }
}
