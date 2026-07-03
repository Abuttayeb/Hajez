import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _obscureCurrent = true, _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final u = await AuthService.getUser();
    if (u != null && mounted) {
      setState(() {
        _nameCtrl.text = u['name']?.toString() ?? '';
        _phoneCtrl.text = u['phone']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) { _snack('الاسم والهاتف مطلوبان', error: true); return; }
    setState(() => _savingProfile = true);
    final res = await AuthService.updateProfile(name: name, phone: phone);
    setState(() => _savingProfile = false);
    if (res['user'] != null) {
      _snack(res['message']?.toString() ?? 'تم التحديث');
      if (mounted) Navigator.pop(context, true);
    } else {
      _snack(res['message']?.toString() ?? 'حدث خطأ', error: true);
    }
  }

  void _changePassword() async {
    final current = _currentPassCtrl.text;
    final newPass = _newPassCtrl.text;
    if (current.isEmpty || newPass.isEmpty) { _snack('املأ حقلي كلمة السر', error: true); return; }
    if (newPass.length < 6) { _snack('كلمة السر الجديدة 6 أحرف على الأقل', error: true); return; }
    setState(() => _savingPassword = true);
    final res = await AuthService.changePassword(currentPassword: current, newPassword: newPass);
    setState(() => _savingPassword = false);
    if (res['message'] != null && res['success'] != false) {
      _snack(res['message'].toString());
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
    } else {
      _snack(res['message']?.toString() ?? 'حدث خطأ', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('البيانات الأساسية', style: AppText.heading3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline, color: AppColors.primary))),
              const SizedBox(height: 12),
              TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: _savingProfile
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(onPressed: _saveProfile, child: const Text('حفظ البيانات'))),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('تغيير كلمة السر', style: AppText.heading3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              TextField(
                controller: _currentPassCtrl,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'كلمة السر الحالية',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  suffixIcon: IconButton(icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey), onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'كلمة السر الجديدة (6 أحرف على الأقل)',
                  prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
                  suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.grey), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: _savingPassword
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(onPressed: _changePassword, child: const Text('تغيير كلمة السر'))),
              const SizedBox(height: 8),
              const Text('عند التغيير سيتم تسجيل الخروج من كل الأجهزة الأخرى تلقائياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.grey), textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
    );
  }
}
