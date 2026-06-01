import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await AuthService.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (res['token'] != null) {
        await AuthService.saveSession(res['token'], res['role'] ?? 'customer', res['user'] ?? {});
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else { _showError(res['message'] ?? 'بيانات خاطئة'); }
    } catch (_) { _showError('تعذر الاتصال بالسيرفر'); }
    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 280, width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  LOGO_BASE64.isEmpty
                      ? const Icon(Icons.home_work_outlined, size: 80, color: Colors.white)
                      : Image.memory(base64Decode(LOGO_BASE64), height: 120),
                  const SizedBox(height: 12),
                  const Text('مرحباً بك', style: TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 14)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 8),
                  const Text('تسجيل الدخول', style: AppText.heading1),
                  const SizedBox(height: 4),
                  const Text('أدخل بياناتك للمتابعة', style: AppText.bodyGrey),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary)),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl, obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 28),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ElevatedButton(onPressed: _login, child: const Text('دخول')),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('ما عندك حساب؟', style: AppText.bodyGrey),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                      child: const Text('إنشاء حساب جديد', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
