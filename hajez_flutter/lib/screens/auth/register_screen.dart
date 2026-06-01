import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'customer';
  bool _loading = false;
  bool _obscure = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await AuthService.register(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), phone: _phoneCtrl.text.trim(), password: _passCtrl.text, role: _role);
      if (res['token'] != null) {
        await AuthService.saveSession(res['token'], res['role'] ?? 'customer', res['user'] ?? {});
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else { _showError(res['message'] ?? 'حدث خطأ'); }
    } catch (_) { _showError('تعذر الاتصال'); }
    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180, width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                LOGO_BASE64.isEmpty ? const Icon(Icons.home_work_outlined, size: 60, color: Colors.white) : Image.memory(base64Decode(LOGO_BASE64), height: 70),
                const SizedBox(height: 8),
                const Text('إنشاء حساب جديد', style: TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
              ])),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('مرحباً!', style: AppText.heading1),
                  const SizedBox(height: 4),
                  const Text('أنشئ حسابك للبدء', style: AppText.bodyGrey),
                  const SizedBox(height: 24),
                  TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline, color: AppColors.primary)), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary)), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'رقم الجوال', prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary)), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passCtrl, obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey), onPressed: () => setState(() => _obscure = !_obscure)),
                    ),
                    validator: (v) => v!.length < 6 ? '6 أحرف على الأقل' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: AppColors.dark)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _roleCard('customer', 'زبون', Icons.person_outline, 'احجز مزارع وشاليهات')),
                    const SizedBox(width: 12),
                    Expanded(child: _roleCard('owner', 'مالك مزرعة', Icons.home_work_outlined, 'أضف وأدر مزارعك')),
                  ]),
                  const SizedBox(height: 24),
                  _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : ElevatedButton(onPressed: _register, child: const Text('إنشاء الحساب')),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('عندك حساب؟', style: AppText.bodyGrey),
                    TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('سجّل دخولك', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(String value, String title, IconData icon, String sub) {
    final sel = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary.withOpacity(0.08) : AppColors.greyLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Column(children: [
          Icon(icon, color: sel ? AppColors.primary : AppColors.grey, size: 28),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: sel ? AppColors.primary : AppColors.dark, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: sel ? AppColors.secondary : AppColors.grey, fontSize: 10, fontFamily: 'Cairo'), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
