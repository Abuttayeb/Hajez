import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';
import '../owner/owner_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  String? _role;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    final user = await AuthService.getUser();
    final role = await AuthService.getRole();
    setState(() { _user = user; _role = role; });
  }

  void _logout() async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل أنت متأكد؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (confirm == true) { await AuthService.logout(); if (mounted) Navigator.pushReplacementNamed(context, '/login'); }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _role == 'owner';
    final name = _user?['name'] ?? '';
    final email = _user?['email'] ?? '';
    final initial = name.isNotEmpty ? name[0] : 'م';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(children: [
              CircleAvatar(radius: 40, backgroundColor: Colors.white24,
                child: Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white, fontFamily: 'Cairo'))),
              const SizedBox(height: 12),
              Text(name, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text(email, style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Text(isOwner ? '🏡 مالك مزرعة' : '👤 زبون', style: const TextStyle(color: AppColors.white, fontFamily: 'Cairo')),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          if (isOwner) ...[
            _section('لوحة التحكم', [
              _item(Icons.dashboard_outlined, 'لوحة تحكم المالك', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()))),
              _item(Icons.agriculture_outlined, 'مزارعي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()))),
              _item(Icons.book_outlined, 'طلبات الحجز', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()))),
            ]),
            const SizedBox(height: 12),
          ],
          _section('الحساب', [
            _item(Icons.person_outline, 'تعديل الملف الشخصي', () {}),
            _item(Icons.notifications_outlined, 'الإشعارات', () {}),
            _item(Icons.help_outline, 'المساعدة والدعم', () {}),
            _item(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () {}),
          ]),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('حاجز v1.0.0', style: TextStyle(color: AppColors.grey, fontFamily: 'Cairo', fontSize: 12))),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(bottom: 8, right: 4), child: Text(title, style: AppText.small.copyWith(fontWeight: FontWeight.bold))),
      Container(decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: items)),
    ],
  );

  Widget _item(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 22),
    title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
    onTap: onTap,
  );
}
