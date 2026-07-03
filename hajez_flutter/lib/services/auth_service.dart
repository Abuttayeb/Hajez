import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static final _api = ApiClient.instance;

  static Future<Map<String, dynamic>> register({required String name, required String email, required String phone, required String password, required String role}) async {
    try {
      final res = await _api.post('/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'role': role,
      });
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final res = await _api.post('/login', data: {'email': email, 'password': password});
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
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

  /// تعديل الاسم والهاتف — وتحديث النسخة المحفوظة محلياً
  static Future<Map<String, dynamic>> updateProfile({required String name, required String phone}) async {
    try {
      final res = await _api.put('/profile', data: {'name': name, 'phone': phone});
      final map = Map<String, dynamic>.from(res as Map);
      if (map['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(map['user']));
      }
      return map;
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  /// تغيير كلمة السر (يتطلب الحالية)
  static Future<Map<String, dynamic>> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final res = await _api.post('/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }
}
