import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class FcmService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null) await _saveToken(token);

    messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen((message) {
      // foreground notification - يمكن إضافة local notification لاحقاً
    });
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);

    final authToken = prefs.getString('token');
    if (authToken == null) return;

    await http.post(
      Uri.parse('$BASE_URL/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'fcm_token': token}),
    );
  }
}
