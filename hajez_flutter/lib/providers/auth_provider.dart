import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// إدارة حالة المصادقة مركزياً:
/// أي شاشة تقدر تقرأ المستخدم/الدور الحالي أو تستمع لتغيّر حالة الدخول
/// بدون إعادة قراءة SharedPreferences كل مرة.
class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _role;
  bool _initialized = false;
  bool _loading = false;

  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  bool get isLoggedIn => _user != null;
  bool get isOwner => _role == 'owner';
  bool get initialized => _initialized;
  bool get loading => _loading;

  /// تُستدعى مرة عند إقلاع التطبيق لتحميل الجلسة المحفوظة
  Future<void> init() async {
    _user = await AuthService.getUser();
    _role = await AuthService.getRole();
    _initialized = true;
    notifyListeners();
  }

  /// تسجيل الدخول: ترجع null عند النجاح أو رسالة الخطأ عند الفشل
  Future<String?> login({required String email, required String password}) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await AuthService.login(email: email, password: password);
      if (res['success'] == true && res['token'] != null) {
        final user = Map<String, dynamic>.from(res['user'] as Map);
        final role = (res['role'] ?? user['role'] ?? 'customer').toString();
        await AuthService.saveSession(res['token'].toString(), role, user);
        _user = user;
        _role = role;
        return null;
      }
      return (res['message'] ?? 'فشل تسجيل الدخول، تحقق من البيانات').toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// إنشاء حساب: ترجع null عند النجاح أو رسالة الخطأ عند الفشل
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await AuthService.register(
          name: name, email: email, phone: phone, password: password, role: role);
      if (res['success'] == true && res['token'] != null) {
        final user = Map<String, dynamic>.from(res['user'] as Map);
        final userRole = (res['role'] ?? user['role'] ?? role).toString();
        await AuthService.saveSession(res['token'].toString(), userRole, user);
        _user = user;
        _role = userRole;
        return null;
      }
      return (res['message'] ?? 'فشل إنشاء الحساب، حاول مجدداً').toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _role = null;
    notifyListeners();
  }

  /// تحديث بيانات المستخدم محلياً (بعد تعديل الملف الشخصي مثلاً)
  Future<void> refreshUser() async {
    _user = await AuthService.getUser();
    _role = await AuthService.getRole();
    notifyListeners();
  }
}
